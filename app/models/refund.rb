# frozen_string_literal: true

class Refund < ApplicationRecord
  belongs_to :refunder, class_name: 'User'
  belongs_to :refund_method, class_name: 'PaymentMethod'
  has_one :invoice, dependent: :nullify
  has_many :refund_article_details, dependent: :destroy
  has_many :articles, through: :refund_article_details
  has_many :refund_subscription_details, dependent: :destroy
  has_many :subscription_offers, through: :refund_subscription_details
end
