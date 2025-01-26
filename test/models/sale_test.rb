# frozen_string_literal: true

require 'test_helper'

class SaleTest < ActiveSupport::TestCase
  def setup
    @sale = sales(:ironman_cable_6_months)
    @offer1 = subscription_offers(:month)
    @offer12 = subscription_offers(:year)
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

  test 'should return false if no subscription offer' do
    Sale.destroy_all
    SubscriptionOffer.destroy_all
    assert_not @sale.send :generate_sales_subscription_offers, 30
  end

  test 'should return if not exhaustive' do
    Sale.destroy_all
    SubscriptionOffer.destroy_all
    SubscriptionOffer.create!(duration: 2, price: 50)
    assert_not @sale.send :generate_sales_subscription_offers, 11
  end

  test 'should not present offer12' do
    @sale.sales_subscription_offers.destroy_all
    @sale.send :generate_sales_subscription_offers, 11
    assert_equal 11, @sale.sales_subscription_offers.first.quantity
    assert_equal @sale.sales_subscription_offers.last, @sale.sales_subscription_offers.first
  end
end
