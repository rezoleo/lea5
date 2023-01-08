# frozen_string_literal: true

class Subscription < ApplicationRecord
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :cannot_change_after_cancelled, :cannot_change_duration, on: :update

  private

  def cannot_change_after_cancelled
    return if cancelled_at_was.nil?

    errors.add(:cancelled_at, 'Subscription has already been cancelled')
  end

  def cannot_change_duration
    return if changes[:duration].nil?

    errors.add(:duration, 'Duration is immutable')
  end
end
