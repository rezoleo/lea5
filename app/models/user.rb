# frozen_string_literal: true

class User < ApplicationRecord
  before_save :downcase_email
  before_save :upcase_room

  validates :firstname, presence: true, allow_blank: false
  validates :lastname, presence: true, allow_blank: false
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  validates :room, presence: true, allow_blank: false, uniqueness: true

  private

  def downcase_email
    email.downcase!
  end

  def upcase_room
    room.upcase!
  end
end
