# frozen_string_literal: true

class Sale < ApplicationRecord
  belongs_to :seller, class_name: 'User'
  belongs_to :client, class_name: 'User'
  belongs_to :payment_methods
  has_one :invoice, dependent: :nullify
  has_many :refunds, dependent: :destroy
  has_many :sale_article_details, dependent: :destroy
  has_many :articles, through: :sale_article_details
  has_many :sale_subscription_details, dependent: :destroy
  has_many :subscription_offers, through: :sale_subscription_details
end
