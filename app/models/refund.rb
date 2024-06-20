# frozen_string_literal: true

class Refund < ApplicationRecord
  belongs_to :refunder, class_name: 'User'
  belongs_to :refund_method, class_name: 'PaymentMethod'
  belongs_to :sale
  has_one :invoice, dependent: :nullify
  has_many :article_refunds, dependent: :destroy
  has_many :articles, through: :article_refunds
  has_many :refund_subscription_offers, dependent: :destroy
  has_many :subscription_offers, through: :refund_subscription_offers
end
