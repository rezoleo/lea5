# frozen_string_literal: true

require 'test_helper'

class SaleTest < ActiveSupport::TestCase
  def setup
    @sale = sales(:one)
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

  test 'total_price should be present' do
    @sale.total_price = nil
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
end
