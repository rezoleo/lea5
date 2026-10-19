# frozen_string_literal: true

class ArticlesRefund < ApplicationRecord
  belongs_to :refund
  belongs_to :article

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
