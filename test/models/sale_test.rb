# frozen_string_literal: true

require 'test_helper'

class SaleTest < ActiveSupport::TestCase
  def setup
    @user = users(:ironman)
    @sale = sales(:ironman_cable_6_months)
    @sale.duration = 6
    @sale.remaining_duration = 0

    @offer1 = subscription_offers(:month)
    @offer12 = subscription_offers(:year)

    @payment_method = payment_methods(:credit_card)
    @article = articles(:cable)
  end

  test 'should be valid' do
    assert_predicate @sale, :valid?
  end

  test 'client_id should be present' do
    @sale.client_id = nil
    assert_not_predicate @sale, :valid?
  end

  test 'seller_id can be null' do
    @sale.seller_id = nil
    assert_predicate @sale, :valid?
  end

  test 'payment_method should be present' do
    @sale.payment_method_id = nil
    assert_not_predicate @sale, :valid?
  end

  test 'invoice_id should be present' do
    @sale.invoice_id = nil
    assert_not_predicate @sale, :valid?
  end

  test 'destroy sale should destroy articles_sales' do
    assert_difference 'ArticlesSale.count', -1 do
      @sale.destroy
    end
  end

  test 'destroy sale should destroy sales_subscription_offers' do
    assert_difference 'SalesSubscriptionOffer.count', -1 do
      @sale.destroy
    end
  end

  test 'destroy sale should destroy refunds' do
    assert_difference 'Refund.count', -1 do
      @sale.destroy
    end
  end

  test 'verify method should set the date if nil' do
    @sale.verified_at = nil
    @sale.verify
    assert_in_delta Time.zone.now, @sale.verified_at, 1.second
  end

  test 'verify method should not change date is not nil' do
    @sale.verified_at = 3.days.ago
    @sale.verify
    assert_in_delta 3.days.ago, @sale.verified_at, 1.second
  end

  test 'subscription offers must be exhaustive' do
    Sale.destroy_all
    SubscriptionOffer.destroy_all
    SubscriptionOffer.create!(duration: 2, price: 50)
    sale = Sale.build_with_invoice(
      {
        client: @user,
        duration: 11,
        payment_method: @payment_method
      },
      seller: @user
    )
    assert_predicate sale, :invalid?
    assert sale.errors.added? :base, 'Subscription offers are not exhaustive!'
  end

  test 'should not present offer12' do
    sale = Sale.build_with_invoice(
      {
        client: @user,
        duration: 11,
        payment_method: @payment_method
      },
      seller: @user
    )
    assert_equal 11, sale.sales_subscription_offers.first.quantity
    assert_equal 1, sale.sales_subscription_offers.length
  end

  test 'should preemptively reject duplicate article sales' do
    sale_attributes = {
      client: @user,
      duration: 0,
      payment_method: @payment_method,
      articles_sales: [
        ArticlesSale.new(article: @article, quantity: 1),
        ArticlesSale.new(article: @article, quantity: 1) # Duplicated article
      ]
    }
    sale = Sale.build_with_invoice(sale_attributes, seller: @user)

    assert_predicate sale, :invalid?
    assert sale.errors.added? :base, 'Please merge the quantities of the same articles'
  end
end
