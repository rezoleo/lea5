# frozen_string_literal: true

class Article < ApplicationRecord
  has_many :articles_sales, dependent: :restrict_with_exception
  has_many :sales, through: :articles_sales
  has_many :articles_refunds, dependent: :restrict_with_exception
  has_many :refunds, through: :articles_refunds
end
