# frozen_string_literal: true

class User < ApplicationRecord
  before_save :downcase_email
  before_save :format_room

  validates :firstname, presence: true, allow_blank: false
  validates :lastname, presence: true, allow_blank: false
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  VALID_ROOM_REGEX = /\A([A-F][0-3][0-9]{2}[a-b]?|DF[1-4])\z/i.freeze
  validates :room, presence: true, format: { with: VALID_ROOM_REGEX }, uniqueness: true

  private

  def downcase_email
    email.downcase!
  end

  def format_room
    self.room = room.downcase.upcase_first
  end
end
