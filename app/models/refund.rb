# frozen_string_literal: true

class Refund < ApplicationRecord
  belongs_to :refunder, class_name: 'User', optional: true
  belongs_to :refund_method, class_name: 'PaymentMethod'
  belongs_to :sale
  belongs_to :invoice
  has_many :articles_refunds, dependent: :destroy
  has_many :articles, through: :articles_refunds
  has_many :refunds_subscription_offers, dependent: :destroy
  has_many :subscription_offers, through: :refunds_subscription_offers

  def total_price
    total = Money.new(0)
    articles_refunds.each do |rec|
      total += rec.quantity * rec.article.price
    end
    refunds_subscription_offers.each do |rec|
      total += rec.quantity * rec.subscription_offer.price
    end
    total
  end
end
