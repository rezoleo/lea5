# frozen_string_literal: true

class User < ApplicationRecord
  has_many :machines, -> { order created_at: :asc }, dependent: :destroy, inverse_of: :user
  has_many :subscriptions, dependent: :destroy

  before_save :downcase_email
  before_save :format_room

  validates :firstname, presence: true, allow_blank: false
  validates :lastname, presence: true, allow_blank: false
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  VALID_ROOM_REGEX = /\A([A-F][0-3][0-9]{2}[a-b]?|DF[1-4])\z/i
  validates :room, presence: true, format: { with: VALID_ROOM_REGEX }, uniqueness: true

  # @return [Array<String>]
  attr_accessor :groups

  def current_subscription
    subscriptions.where(cancelled_at: nil).order(end_at: :desc).first
  end

  def subscription_expiration
    current_subscription&.end_at # Safe operator, return nil if object is nil
  end

  # @param [Integer] duration subscription duration in months
  # @return [Subscription] the newly created subscription
  def extend_subscription(duration:)
    start_at = subscription_expired? ? Time.current : subscription_expiration
    subscriptions.new(start_at:, end_at: start_at + duration.months)
  end

  def cancel_current_subscription!
    current_subscription&.cancel!

    save!
  end

  def self.upsert_from_auth_hash(auth_hash)
    user = find_or_initialize_by("#{auth_hash[:provider]}_id": auth_hash[:uid])
    user.update(
      firstname: auth_hash[:info][:first_name],
      lastname: auth_hash[:info][:last_name],
      email: auth_hash[:info][:email],
      room: auth_hash[:extra][:raw_info][:room]
    )
    user.groups = auth_hash[:extra][:raw_info][:groups]
    user.save!
    user
  end

  def admin?
    return false if groups.nil?

    groups.include?('rezoleo')
  end

  private

  def downcase_email
    email.downcase!
  end

  def format_room
    self.room = room.downcase.upcase_first
  end

  def subscription_expired?
    subscription_expiration.nil? || (subscription_expiration < Time.current)
  end
end
