# frozen_string_literal: true

class Sale < ApplicationRecord
  belongs_to :seller, class_name: 'User', optional: true
  belongs_to :client, class_name: 'User'
  belongs_to :payment_method
  belongs_to :invoice
  has_one :subscription, dependent: :destroy
  has_many :refunds, dependent: :destroy
  has_many :articles_sales, dependent: :destroy
  has_many :articles, through: :articles_sales
  has_many :sales_subscription_offers, dependent: :destroy
  has_many :subscription_offers, through: :sales_subscription_offers

  accepts_nested_attributes_for :articles_sales

  validates :total_price, presence: true

  def verify
    self.verified_at = Time.zone.now if verified_at.nil?
  end

  def generate(duration:, seller:)
    generate_sales_subscription_offers duration.to_i
    self.seller = seller
    create_associated_subscription duration.to_i unless duration.to_i.zero?
    self.total_price = compute_total_price
    verify if payment_method.auto_verify
    generate_invoice
  end

  def compute_total_price
    total = 0
    articles_sales.each do |rec|
      total += rec.quantity * Article.find(rec.article_id).price
    end
    sales_subscription_offers.each do |rec|
      total += rec.quantity * SubscriptionOffer.find(rec.subscription_offer.id).price
    end
    total
  end

  def generate_invoice
    return if invoice

    self.invoice = Invoice.new
    invoice.generate_from(self)
  end

  def empty?
    articles_sales.empty? && sales_subscription_offers.empty?
  end

  private

  def generate_sales_subscription_offers(duration)
    subscription_offers = SubscriptionOffer.order(duration: :desc)
    if subscription_offers.empty?
      errors.add(:base, 'There are no subscription offers registered!')
      return false
    end
    subscription_offers.each do |offer|
      break if duration.zero?

      quantity = duration / offer.duration
      if quantity.positive?
        sales_subscription_offers.new(subscription_offer_id: offer.id, quantity: quantity)
        duration -= quantity * offer.duration
      end
    end
    return unless duration.zero?

    errors.add(:base, 'Subscription offers are not exhaustive!')
    false
  end

  def create_associated_subscription(duration)
    self.subscription = client.extend_subscription(duration: duration)
  end
end
