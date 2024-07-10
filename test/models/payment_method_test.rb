# frozen_string_literal: true

require 'test_helper'

class PaymentMethodTest < ActiveSupport::TestCase
  def setup
    @payment_method = payment_methods(:one)
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

  test 'payment_method should soft delete' do
    assert_no_difference 'PaymentMethod.count' do
      @payment_method.soft_delete
    end
  end

  test 'payment_method should be destroyed if no sales' do
    @payment_method.sales.destroy_all
    @payment_method.refunds.destroy_all
    assert_difference 'PaymentMethod.count', -1 do
      @payment_method.destroy
    end
  end

  test 'article should be destroyable' do
    @payment_method.sales.destroy_all
    @payment_method.refunds.destroy_all
    assert_predicate @payment_method, :destroy
  end

  test 'payment_method should not destroy if dependant' do
    assert_no_difference 'PaymentMethod.count' do
      assert_not_predicate @payment_method, :destroy
    end

    assert_predicate @payment_method, :persisted?
    assert_includes @payment_method.errors[:base], 'Cannot delete record because dependent sales exist'
  end
end
