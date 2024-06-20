# frozen_string_literal: true

class PaymentMethod < ApplicationRecord
  has_many :sales, dependent: :restrict_with_exception
  has_many :refunds, foreign_key: 'refund_method', dependent: :restrict_with_exception, inverse_of: :refund_method
end
