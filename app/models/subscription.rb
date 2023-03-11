# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user

  validates :start_at, presence: true
  validates :end_at, comparison: { greater_than: :start_at }
  validate :cannot_change_after_cancelled, on: :update

  def cancel!
    self.cancelled_at = Time.current
    save!
  end

  private

  def cannot_change_after_cancelled
    return if cancelled_at_was.nil?

    errors.add(:cancelled_at, 'Subscription has already been cancelled')
  end
end
