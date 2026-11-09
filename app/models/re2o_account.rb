# frozen_string_literal: true

# A re2o account from the migration snapshot. A lea5 user claims it once to recover
# their remaining internet access, their room and their machines.
class Re2oAccount < ApplicationRecord
  MIGRATION_REASON = 'Migration re2o'

  class ClaimError < StandardError; end

  belongs_to :claimed_by, class_name: 'User', foreign_key: 'claimed_by_user_id', optional: true,
                          inverse_of: :re2o_account

  normalizes :pseudo, with: ->(pseudo) { pseudo.strip.downcase }
  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :ntlm_hash, with: ->(hash) { hash.strip.downcase }

  validates :pseudo, presence: true, uniqueness: true
  validates :end_at, presence: true

  scope :unclaimed, -> { where(claimed_by_user_id: nil) }

  # Claiming changes claimed_at, which invalidates every link already sent
  generates_token_for :claim, expires_in: 1.day do
    claimed_at
  end

  # @param [String] identifier re2o pseudo or email
  # @return [Re2oAccount, nil]
  def self.lookup(identifier)
    value = identifier.to_s.strip.downcase
    return if value.blank?

    unclaimed.find_by(pseudo: value) || unclaimed.find_by(email: value)
  end

  # re2o stores the NTLM (MD4) hash of the account password
  def password_matches?(password)
    return false if ntlm_hash.blank? || password.blank?

    ActiveSupport::SecurityUtils.secure_compare(OpenSSL::Digest::MD4.hexdigest(password.encode('utf-16le')), ntlm_hash)
  end

  def masked_email
    return if email.blank?

    local, domain = email.split('@', 2)
    tld = domain.to_s[/\.[^.]+\z/] # nil when the domain has no dot
    "#{local[0]}***@#{domain.to_s[0]}***#{tld}"
  end

  def claimed?
    claimed_by_user_id.present?
  end

  def claim_skipped_anything?
    report = claim_report || {}
    [report['access'], report['room'], *report['machines']].compact.any? { |item| item['status'] == 'skipped' }
  end

  # Attaches this account to the user and imports what can be imported, never overwriting existing data.
  # @param [User] user
  # @return [Hash] the claim report, also saved in claim_report
  def claim!(user)
    raise ClaimError, 'Your lea5 account has already been migrated from re2o.' if user.re2o_account.present?

    transaction do
      lock!
      raise ClaimError, 'This re2o account has already been migrated.' if claimed?

      update!(claimed_by: user, claimed_at: Time.current)
      update!(claim_report: { 'access' => import_access(user),
                              'room' => import_room(user),
                              'machines' => machines.map { |m| import_machine(user, m['mac'], m['name']) } })
      claim_report
    end
  rescue ActiveRecord::RecordNotUnique
    raise ClaimError, 'Your lea5 account has already been migrated from re2o.'
  end

  private

  # Remaining re2o time is added after the current access, so nothing paid is lost
  def import_access(user)
    remaining = end_at - Time.current
    return { 'status' => 'skipped', 'reason' => 'Your re2o access has already ended' } unless remaining.positive?

    start_at = [user.internet_expiration, Time.current].compact.max
    access = user.free_accesses.create!(reason: MIGRATION_REASON, start_at: start_at, end_at: start_at + remaining)
    { 'status' => 'imported', 'days' => (remaining / 1.day).ceil, 'end_at' => access.end_at.iso8601 }
  end

  def import_room(user)
    number = room.to_s.strip.upcase
    return { 'status' => 'skipped', 'reason' => 'No room in re2o' } if number.blank?
    return { 'status' => 'kept', 'number' => user.room.number } if user.room

    target = Room.find_by(number: number)
    return { 'status' => 'skipped', 'number' => number, 'reason' => 'Room not found in lea5' } if target.nil?
    return { 'status' => 'skipped', 'number' => number, 'reason' => 'Room is assigned to someone else' } if target.user

    target.update!(user: user)
    { 'status' => 'imported', 'number' => number }
  end

  def import_machine(user, mac, name)
    report = { 'mac' => mac, 'name' => name.presence || 're2o machine' }
    # Savepoint: a failing machine must not roll back the whole claim
    self.class.transaction(requires_new: true) do
      existing = Machine.find_by(mac: mac)
      next report.merge('status' => 'skipped', 'reason' => 'Already on your account') if existing&.user == user
      next report.merge('status' => 'skipped', 'reason' => 'Registered on another account') if existing

      machine = user.machines.create(name: report['name'], mac: mac)
      if machine.persisted?
        report.merge('status' => 'imported', 'ip' => machine.ip.ip.to_s)
      else
        report.merge('status' => 'skipped', 'reason' => machine.errors.full_messages.to_sentence)
      end
    end
  rescue ActiveRecord::StatementInvalid # e.g. a MAC that PostgreSQL refuses to cast
    report.merge('status' => 'skipped', 'reason' => 'Invalid MAC address')
  end
end
