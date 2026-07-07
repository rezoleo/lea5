# frozen_string_literal: true

# It is recommended to instantiate a refund using {Refund.create_with_credit_note}
class Refund < ApplicationRecord
  belongs_to :refunder, class_name: 'User', optional: true
  belongs_to :refund_method, class_name: 'PaymentMethod'
  belongs_to :sale
  belongs_to :invoice
  has_many :articles_refunds, dependent: :destroy
  has_many :articles, through: :articles_refunds

  # Prorated credit for the cut subscription. NULL means no subscription was cut.
  monetize :subscription_refund_cents, allow_nil: true

  # Whether to cut the subscription, and the refund timestamp.
  attr_accessor :refund_subscription, :cut_at

  validate :not_empty_refund
  validate :subscription_must_be_refundable

  # @return [Boolean] whether this refund cut the sale's subscription
  def subscription_refunded?
    subscription_refund_cents.present?
  end

  # @return [Money]
  def credited_amount
    total = Money.new(0)
    articles_refunds.each { |rec| total += rec.quantity * rec.article.price }
    total += subscription_refund if subscription_refunded?
    total
  end

  # Builds (without saving) a refund and its credit-note invoice for the given sale.
  # @return [Refund]
  def self.build_with_credit_note(sale:, refund_method:, refunder:, refund_scope: {}, cut_at: Time.current)
    new(sale: sale, refund_method: refund_method, refunder: refunder) do |refund|
      refund.refund_subscription = refund_scope.fetch(:refund_subscription, false)
      refund.cut_at = cut_at
      refund.articles_refunds = build_articles_refunds(sale, refund_scope.fetch(:article_ids, []))
      refund.subscription_refund_cents = subscription_credit_cents(sale, cut_at) if refund.refund_subscription
      refund.invoice = Invoice.build_from_refund(refund)
    end
  end

  # Atomically persists the refund and cuts the refunded subscription as of +cut_at+.
  # The sale row is locked to serialize concurrent refunds, so an article can never be
  # refunded twice and a subscription can never be cut twice.
  # @return [Refund] persisted on success; otherwise carries validation errors (see #persisted?)
  def self.create_with_credit_note(sale:, refund_method:, refunder:, refund_scope: {}, cut_at: Time.current)
    refund = nil
    transaction do
      sale.lock!
      refund = build_with_credit_note(sale: sale, refund_method: refund_method, refunder: refunder,
                                      refund_scope: refund_scope, cut_at: cut_at)
      raise ActiveRecord::Rollback unless refund.save

      sale.subscription&.update!(cancelled_at: cut_at) if refund_scope.fetch(:refund_subscription, false)
    end
    refund
  end

  # Prorated subscription credit in cents, or nil when the sale has no subscription.
  def self.subscription_credit_cents(sale, cut_at)
    sale.subscription&.refund_amount(as_of: cut_at)&.cents
  end
  private_class_method :subscription_credit_cents

  # Article lines selected for refund, filtered to those not already refunded.
  def self.build_articles_refunds(sale, article_ids)
    return [] if article_ids.blank?

    sale.refundable_article_sales.where(article_id: article_ids).map do |article_sale|
      ArticlesRefund.new(article: article_sale.article, quantity: article_sale.quantity)
    end
  end
  private_class_method :build_articles_refunds

  private

  def not_empty_refund
    return if articles_refunds.present? || subscription_refunded?

    errors.add(:base, 'Cannot create an empty refund, select at least an article or the subscription')
  end

  def subscription_must_be_refundable
    return unless refund_subscription
    return if sale.subscription&.refundable?

    errors.add(:base, 'The subscription cannot be refunded (already ended or cancelled)')
  end
end
