# frozen_string_literal: true

require 'test_helper'

class RefundTest < ActiveSupport::TestCase
  def setup
    @refund = refunds(:one)
  end

  test 'destroy refund should destroy articles_refunds' do
    assert_difference 'ArticlesRefund.count', -1 do
      @refund.destroy
    end
  end

  test 'destroy refun should destroy refunds_subscription_offers' do
    assert_difference 'RefundsSubscriptionOffer.count', -1 do
      @refund.destroy
    end
  end
end
