# frozen_string_literal: true

class User < ApplicationRecord
  has_many :machines, -> { order created_at: :asc }, dependent: :destroy, inverse_of: :user

  before_save :downcase_email
  before_save :format_room

  validates :firstname, presence: true, allow_blank: false
  validates :lastname, presence: true, allow_blank: false
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  VALID_ROOM_REGEX = /\A([A-F][0-3][0-9]{2}[a-b]?|DF[1-4])\z/i
  validates :room, presence: true, format: { with: VALID_ROOM_REGEX }, uniqueness: true

  def self.upsert_from_auth_hash(auth_hash)
    user = find_or_initialize_by("#{auth_hash[:provider]}_id": auth_hash[:uid])
    user.update(
      firstname: auth_hash[:info][:first_name],
      lastname: auth_hash[:info][:last_name],
      email: auth_hash[:info][:email],
      room: auth_hash[:extra][:raw_info][:room]
    )
    user.save!
    user
  end

  private

  def downcase_email
    email.downcase!
  end

  def format_room
    self.room = room.downcase.upcase_first
  end
end
