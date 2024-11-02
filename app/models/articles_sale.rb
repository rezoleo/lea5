# frozen_string_literal: true

class ArticlesSale < ApplicationRecord
  belongs_to :sale
  belongs_to :article

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  validates :article_id, uniqueness: {
    scope: :sale_id,
    message: 'can only be added once to a sale, please merge the quantities of the same articles'
  }
end
