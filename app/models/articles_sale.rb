# frozen_string_literal: true

class ArticlesSale < ApplicationRecord
  belongs_to :sale
  belongs_to :article

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # We already have a primary key constraint on the column pair, creating a unique index
  # See migration 20240720124420_create_article_sale_details.rb
  # We might want to chime in on this issue: https://github.com/rubocop/rubocop-rails/issues/231
  # TODO: Use https://github.com/gregnavis/active_record_doctor as a better validator?
  validates :article_id, uniqueness: { # rubocop:disable Rails/UniqueValidationWithoutIndex
    scope: :sale_id,
    message: 'can only be added once to a sale, please merge the quantities of the same articles'
  }
end
