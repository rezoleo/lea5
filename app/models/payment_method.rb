# frozen_string_literal: true

class PaymentMethod < ApplicationRecord
  has_many :sales, dependent: :restrict_with_exception
  has_many :refunds, foreign_key: 'refund_method_id', dependent: :restrict_with_exception, inverse_of: :refund_method

  validates :name, presence: true, allow_blank: false
  validates :auto_verify, inclusion: { in: [true, false] }

  def soft_delete
    update(deleted_at: Time.zone.now)
  end
end
