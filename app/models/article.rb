# frozen_string_literal: true

class Article < ApplicationRecord
  has_many :sale_article_details, dependent: :restrict_with_exception
  has_many :sales, through: :sale_subscription_details
  has_many :refund_article_details, dependent: :restrict_with_exception
  has_many :refunds, through: :refund_article_details
end
