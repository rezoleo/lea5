# frozen_string_literal: true

class Sale < ApplicationRecord
  belongs_to :seller, class_name: 'User'
  belongs_to :client, class_name: 'User'
  belongs_to :payment_method
  has_one :subscription, dependent: :destroy
  has_one :invoice, dependent: :nullify
  has_many :refunds, dependent: :destroy
  has_many :article_sales, dependent: :destroy
  has_many :articles, through: :article_sales
  has_many :sale_subscription_offers, dependent: :destroy
  has_many :subscription_offers, through: :sale_subscription_offers
end
