# frozen_string_literal: true

require 'test_helper'

class PaymentMethodTest < ActiveSupport::TestCase
  def setup
    @payment_method = payment_methods(:credit_card)
  end

  test 'should be valid' do
    assert_predicate @payment_method, :valid?
  end

  test 'should not be valid without name' do
    @payment_method.name = nil
    assert_not_predicate @payment_method, :valid?
  end

  test 'should not be valid without auto-verify' do
    @payment_method.auto_verify = nil
    assert_not_predicate @payment_method, :valid?
  end

  test 'payment method should soft delete' do
    @payment_method.deleted_at = nil
    assert_no_difference 'PaymentMethod.unscoped.count' do
      @payment_method.soft_delete
    end
    assert_not_predicate @payment_method.deleted_at, :nil?
  end

  test 'soft_delete should not change deleted_at date' do
    @payment_method.deleted_at = 3.days.ago
    before_test = @payment_method.deleted_at
    @payment_method.soft_delete
    assert_equal @payment_method.deleted_at, before_test
  end

  test 'payment_method should be destroyed if no sales' do
    @payment_method.sales.destroy_all
    @payment_method.refunds.destroy_all
    assert_difference 'PaymentMethod.unscoped.count', -1 do
      @payment_method.destroy
    end
  end

  test 'article should be destroyable' do
    @payment_method.sales.destroy_all
    @payment_method.refunds.destroy_all
    assert_predicate @payment_method, :destroy
  end

  test 'payment_method should not destroy if dependant' do
    assert_no_difference 'PaymentMethod.unscoped.count' do
      assert_not_predicate @payment_method, :destroy
    end

    assert_predicate @payment_method, :persisted?
    assert_includes @payment_method.errors[:base], 'Cannot delete record because dependent sales exist'
  end
end
