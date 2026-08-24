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

  # In the form to create a new Sale, also accept fields to create an article_sale
  # form >
  #   sale[duration], sale[payment_method_id]...
  #   sale[articles_sales_attributes][1][article_id], sale[articles_sales_attributes][1][quantity]...
  #   sale[articles_sales_attributes][2][article_id], sale[articles_sales_attributes][2][quantity]...
  # Sale.new(sale_params) => Sale(duration, payment_method) + ArticleSale(article, quantity)
  # (but we use Sale.build_with_invoice instead of Sale.new/Sale.create)
  accepts_nested_attributes_for :articles_sales

  attribute :duration, :integer, default: 0
  # Used to validate subscription offers exhaustiveness
  attr_accessor :remaining_duration

  validates :duration, numericality: { greater_than_or_equal_to: 0 }
  validate :not_empty_sale, unless: ->(sale) { sale.errors.include?(:duration) }
  validate :exhaustive_subscription_offers, unless: ->(sale) { sale.errors.include?(:duration) }
  validate :no_duplicate_article_sale

  def verify
    self.verified_at = Time.zone.now if verified_at.nil?
  end

  def total_price
    total = Money.new(0)
    articles_sales.each do |rec|
      total += rec.quantity * rec.article.price
    end
    sales_subscription_offers.each do |rec|
      total += rec.quantity * rec.subscription_offer.price
    end
    total
  end

  # Article lines of this sale that have not yet been covered by a previous refund.
  # An article can be refunded at most once (it appears at most once per sale).
  # @return [ActiveRecord::Relation<ArticlesSale>]
  def refundable_article_sales
    already_refunded = ArticlesRefund.joins(:refund).where(refunds: { sale_id: id }).select(:article_id)
    articles_sales.where.not(article_id: already_refunded)
  end

  # @param [Hash] attributes
  # @param [User] seller
  def self.build_with_invoice(attributes = {}, seller:)
    new(attributes) do |sale|
      sale.sales_subscription_offers = SubscriptionPricing.basket_for(sale.duration)
      # Check if we have covered the entire subscription duration with subscription offers
      # (e.g., if we offer 12 months and 6 months but the user asks for 4 months, we cannot
      # cover the period and would have a non-zero remaining_duration, invalidated thanks
      # to exhaustive_subscription_offers)
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
end
