# frozen_string_literal: true

# It is recommended to instantiate a new sale using {Sale.build_with_invoice}
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

  attribute :duration, :integer, default: 0
  attr_accessor :remaining_duration

  validates :duration, numericality: { greater_than_or_equal_to: 0 }
  validate :not_empty_sale, unless: ->(sale) { sale.errors.include?(:duration) }
  validate :exhaustive_subscription_offers, unless: ->(sale) { sale.errors.include?(:duration) }
  validate :no_duplicate_article_sale

  def verify
    self.verified_at = Time.zone.now if verified_at.nil?
  end

  def total_price
    total = 0
    articles_sales.each do |rec|
      total += rec.quantity * Article.find(rec.article_id).price
    end
    sales_subscription_offers.each do |rec|
      total += rec.quantity * SubscriptionOffer.find(rec.subscription_offer.id).price
    end
    total
  end

  # @param [Hash] attributes
  # @param [User] seller
  def self.build_with_invoice(attributes = {}, seller:)
    new(attributes) do |sale|
      sale.sales_subscription_offers = generate_sales_subscription_offers(sale.duration)
      cumulated_duration = sale.sales_subscription_offers.sum { |sso| sso.quantity * sso.subscription_offer.duration }
      sale.remaining_duration = sale.duration - cumulated_duration
      sale.seller = seller
      sale.subscription = sale.client.extend_subscription(duration: sale.duration)
      sale.verify if sale.payment_method&.auto_verify
      sale.invoice = Invoice.build_from_sale(sale)
    end
  end

  private

  def not_empty_sale
    return unless articles_sales.empty? && sales_subscription_offers.empty?

    errors.add(:base, 'Cannot create an empty sale, add at least an article or a subscription')
  end

  def exhaustive_subscription_offers
    return if remaining_duration == 0

    errors.add(:base, 'Subscription offers are not exhaustive!')
  end

  def no_duplicate_article_sale
    # The unique constraint on ArticlesSales prevents us from duplicating articles in a single sale,
    # but Rails doesn't rescue from hard DB integrity errors, so we need to validate the association
    # in-memory before to show pretty errors.
    # See https://github.com/rails/rails/issues/20676 that seems very related
    duplicate_article_ids = articles_sales.map(&:article_id).tally.filter { |_, v| v > 1 }
    return if duplicate_article_ids.empty?

    articles_sales
      .filter { |article_sale| article_sale.article_id.in? duplicate_article_ids }
      .each { |article_sale| article_sale.errors.add(:article_id, :taken) }

    errors.add(:base, 'Please merge the quantities of the same articles')
  end

  class << self
    private

    # @param [Integer] duration
    # @return [Array<SalesSubscriptionOffer>]
    def generate_sales_subscription_offers(duration)
      return [] if duration < 0

      subscription_offers = SubscriptionOffer.order(duration: :desc)
      sales_subscription_offers = []
      subscription_offers.each do |offer|
        break if duration == 0

        quantity = duration / offer.duration
        if quantity > 0
          sales_subscription_offers << SalesSubscriptionOffer.new(subscription_offer_id: offer.id, quantity: quantity)
          duration -= quantity * offer.duration
        end
      end

      sales_subscription_offers
    end
  end
end
