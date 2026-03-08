# frozen_string_literal: true

class Room < ApplicationRecord
  has_one :user, foreign_key: :room, primary_key: :number, dependent: :restrict_with_error, inverse_of: :room_record

  validates :number, presence: true, uniqueness: true, length: { maximum: 6 },
                     format: { with: /\A[A-Z0-9]+\z/, message: 'must be uppercase alphanumeric' }
  validates :group, presence: true, length: { maximum: 6 },
                    format: { with: /\A[A-Z0-9]+\z/, message: 'must be uppercase alphanumeric' }
  validates :building, presence: true, inclusion: { in: ('A'..'F').to_a }
  validates :floor, presence: true, inclusion: { in: 0..3 }

  # Returns rooms available for assignment: unoccupied rooms + the room already assigned to the given user
  scope :available_for, lambda { |user|
    occupied = User.where.not(id: user.id).where.not(room: nil).select(:room)
    where.not(number: occupied)
  }
end
