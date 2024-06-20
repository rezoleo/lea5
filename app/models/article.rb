# frozen_string_literal: true

class Article < ApplicationRecord
  has_many :article_sales, dependent: :restrict_with_exception
  has_many :sales, through: :article_sales
  has_many :article_refunds, dependent: :restrict_with_exception
  has_many :refunds, through: :article_refunds
end
