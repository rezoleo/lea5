# frozen_string_literal: true

class FreeAccess < ApplicationRecord
  belongs_to :user
  belongs_to :created_by, class_name: 'User', optional: true

  validates :start_at, presence: true
  validates :end_at, presence: true, comparison: { greater_than: :start_at }
  validates :reason, presence: true, allow_blank: false
end
