# frozen_string_literal: true

class User < ApplicationRecord
  has_many :machines, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :free_accesses, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :room, with: lambda { |room|
    room.strip!

    if /\ADF[1-4]\z/i.match?(room)
      room.upcase
    else
      room.downcase.upcase_first
    end
  }

  validates :firstname, presence: true, allow_blank: false
  validates :lastname, presence: true, allow_blank: false
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  VALID_ROOM_REGEX = /\A([A-F][0-3][0-9]{2}[a-b]?|DF[1-4])\z/
  validates :room, presence: true, format: { with: VALID_ROOM_REGEX }, uniqueness: true

  # @return [Array<String>]
  attr_accessor :groups

  def current_subscription
    subscriptions.where(cancelled_at: nil).order(end_at: :desc).first
  end

  def current_free_access
    free_accesses.order(end_at: :desc).first
  end

  def subscription_expiration
    current_subscription&.end_at # Safe operator, return nil if object is nil
  end

  def internet_expiration
    # .compact removes all nil from an array
    [current_subscription&.end_at, current_free_access&.end_at].compact.max
  end

  # @param [Integer] duration subscription duration in months
  # @return [Subscription] the newly created subscription
  def extend_subscription(duration:)
    start_at = subscription_expired? ? Time.current : subscription_expiration
    subscriptions.new(start_at: start_at, end_at: start_at + duration.months)
  end

  def cancel_current_subscription!
    current_subscription&.cancel!

    save!
  end

  def self.upsert_from_auth_hash(auth_hash)
    user = find_or_initialize_by("#{auth_hash[:provider]}_id": auth_hash[:uid])
    user.update_from_sso(firstname: auth_hash[:info][:first_name],
                         lastname: auth_hash[:info][:last_name],
                         email: auth_hash[:info][:email],
                         room: auth_hash[:extra][:raw_info][:room])
    user.groups = auth_hash[:extra][:raw_info][:groups]
    user.save!
    user
  end

  def update_from_sso(firstname:, lastname:, email:, room:)
    update(firstname:, lastname:, email:, room:)
  end

  def admin?
    return false if groups.nil?

    groups.include?('rezoleo')
  end

  private

  def subscription_expired?
    subscription_expiration.nil? || (subscription_expiration < Time.current)
  end
end
