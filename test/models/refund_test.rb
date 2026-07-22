# frozen_string_literal: true

require 'test_helper'

class RefundTest < ActiveSupport::TestCase
  def setup
    super
    @refund = refunds(:ironman_cable_adapter_4_months)
  end

  test 'destroy refund should destroy articles_refunds' do
    assert_difference 'ArticlesRefund.count', -1 do
      @refund.destroy
    end
  end

  test 'credited_amount sums refunded articles and the stored subscription credit' do
    # cable (2 €) + stored subscription credit (20 €)
    assert_equal Money.new(2200, :eur), @refund.credited_amount
  end

  test 'create_with_credit_note refunds an article and generates a credit note' do
    sale = sales(:ironman_deleted_article)
    article = articles(:deleted_article)

    refund = nil
    assert_difference ['Refund.count', 'ArticlesRefund.count', 'Invoice.count'], 1 do
      refund = Refund.create_with_credit_note(
        sale: sale, refund_method: payment_methods(:cash), refunder: users(:ironman),
        refund_scope: { article_ids: [article.id] }
      )
    end

    assert_predicate refund, :persisted?
    assert_equal [article.id], refund.articles_refunds.map(&:article_id)
    assert_equal Money.new(2000, :eur), refund.credited_amount
    assert_equal 6, refund.invoice.number # next_invoice_number fixture
    assert_equal users(:ironman), refund.invoice.user
  end

  test 'create_with_credit_note cuts the subscription and prorates the credit' do
    sale = sales(:spiderman_1_year) # 1 year (50 €), starts in 2099 => not yet consumed
    subscription = subscriptions(:subscription3)

    refund = nil
    assert_difference 'Refund.count', 1 do
      refund = Refund.create_with_credit_note(
        sale: sale, refund_method: payment_methods(:cash), refunder: users(:ironman),
        refund_scope: { refund_subscription: true }
      )
    end

    assert_predicate refund, :persisted?
    assert_predicate refund, :subscription_refunded?
    assert_equal Money.new(5000, :eur), refund.credited_amount # nothing consumed yet => full refund
    assert_equal 5000, refund.subscription_refund_cents
    assert_not_nil subscription.reload.cancelled_at
    assert_not_predicate subscription, :refundable?
  end

  test 'create_with_credit_note rejects an empty refund' do
    refund = Refund.create_with_credit_note(
      sale: sales(:ironman_deleted_article), refund_method: payment_methods(:cash), refunder: users(:ironman)
    )

    assert_not_predicate refund, :persisted?
    assert refund.errors.added?(:base, 'Cannot create an empty refund, select at least an article or the subscription')
  end

  test 'create_with_credit_note rejects refunding an ended subscription' do
    sale = sales(:pepper_1_year) # subscription2 ended in 2023

    refund = Refund.create_with_credit_note(
      sale: sale, refund_method: payment_methods(:cash), refunder: users(:ironman),
      refund_scope: { refund_subscription: true }
    )

    assert_not_predicate refund, :persisted?
    assert refund.errors.added?(:base, 'The subscription cannot be refunded (already ended or cancelled)')
  end

  test 'create_with_credit_note prevents refunding the same article twice' do
    sale = sales(:ironman_deleted_article)
    article = articles(:deleted_article)
    args = { sale: sale, refund_method: payment_methods(:cash), refunder: users(:ironman),
             refund_scope: { article_ids: [article.id] } }

    assert_predicate Refund.create_with_credit_note(**args), :persisted?

    second = Refund.create_with_credit_note(**args)
    assert_not_predicate second, :persisted?
    assert_empty sale.refundable_article_sales
  end
end
