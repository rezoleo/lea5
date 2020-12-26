# frozen_string_literal: true

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    @subscription = subscriptions(:ironman_subscription)
  end

  test 'subscription is valid' do
    assert @subscription.valid?
  end

  test "payment can't be nil" do
    @subscription.payment = nil
    assert_not @subscription.valid?
  end

  test 'payment must be of a valid format' do
    valid_payments = %w[cash cheque creditCard bankTransfer]
    invalid_payments = ['    ', 'money', 'dollars', 'check']

    valid_payments.each do |valid_payment|
      @subscription.payment = valid_payment
      assert @subscription.valid?, "#{valid_payment.inspect} should be valid"
    end

    invalid_payments.each do |invalid_payment|
      @subscription.payment = invalid_payment
      assert_not @subscription.valid?, "#{invalid_payment.inspect} shouldn't be valid"
    end
  end

  test "duration can't be nil" do
    @subscription.duration = nil
    assert_not @subscription.valid?
  end

  test 'duration should be strictly positive' do
    @subscription.duration = -1
    assert_not @subscription.valid?

    @subscription.duration = 0
    assert_not @subscription.valid?
  end

  test "date can't be nil" do
    @subscription.date = nil
    assert_not @subscription.valid?
  end

  test 'subscriptions should be destroyed when the user is destroyed' do
    owner = @subscription.user
    @subscription.save
    assert_difference 'Subscription.count', -1 do
      owner.destroy
    end
  end
end
