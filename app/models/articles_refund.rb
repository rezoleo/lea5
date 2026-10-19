# frozen_string_literal: true

class ArticlesRefund < ApplicationRecord
  belongs_to :refund
  belongs_to :article

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # @return [Money]
  def total
    quantity && article ? quantity * article.price : Money.new(0)
  end
end
