# frozen_string_literal: true

class Room < ApplicationRecord
  belongs_to :user, optional: true, inverse_of: :room

  validates :number, presence: true, uniqueness: true, length: { maximum: 6 },
                     format: { with: /\A[A-Z0-9]+\z/, message: 'must be uppercase alphanumeric' }
  # A room group represents the natural grouping of rooms. It can be the room number itself or a shared identifier
  validates :group, presence: true, length: { maximum: 6 },
                    format: { with: /\A[A-Z0-9]+\z/, message: 'must be uppercase alphanumeric' }
  validates :building, presence: true, inclusion: { in: ('A'..'F').to_a }
  validates :floor, presence: true, inclusion: { in: 0..3 }
  validates :user_id, uniqueness: true, allow_nil: true

  after_commit :enqueue_room_sync_to_sso, on: [:create, :update], if: :saved_change_to_user_id?

  # Returns rooms available for assignment: unoccupied rooms + the room already assigned to the given user
  scope :available_for, ->(user) { where(user_id: [nil, user.id]).order(:number) }

  private

  def enqueue_room_sync_to_sso
    SyncRoomToSsoJob.perform_later(user_id) if user_id.present?
    SyncRoomToSsoJob.perform_later(user_id_before_last_save) if user_id_before_last_save.present?
  end
end
