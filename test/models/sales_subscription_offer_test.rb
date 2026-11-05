# frozen_string_literal: true

require 'test_helper'

class SalesSubscriptionOfferTest < ActiveSupport::TestCase
  test 'total is zero while quantity or offer is missing' do
    assert_equal Money.new(0), SalesSubscriptionOffer.new.total
  end
end
