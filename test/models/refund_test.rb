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

  test 'destroy refund should destroy refunds_subscription_offers' do
    assert_difference 'RefundsSubscriptionOffer.count', -1 do
      @refund.destroy
    end
  end
end
