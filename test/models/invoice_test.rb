# frozen_string_literal: true

require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  def setup
    @client = users(:ironman)
    @sale = sales(:one)
    @sale.client = @client
    @invoice = invoices(:one)
    @invoice.sale = @sale
  end

  test 'should be valid' do
    assert_predicate @invoice, :valid?
  end

  test 'should generate correct user' do
    assert_equal @invoice.user, @client
  end

  test 'should generate correct hash' do
    expected_hash = {
      sale_date: Time.zone.today,
      issue_date: Time.zone.today,
      client_name: @sale.client.display_name,
      client_address: @sale.client.display_address,
      payment_amount_cent: @sale.verified_at.nil? ? 0 : @sale.total_price,
      payment_method: @sale.payment_method.name,
      payment_date: @sale.verified_at,
      items: @invoice.send(:sales_itemized, @sale)
    }.compact

    assert_equal @invoice.send(:generate_hash, @sale), expected_hash
  end

  test 'should generate json and id from sale' do
    invoice = Invoice.build_from_sale(@sale)

    assert_not_nil invoice.generation_json
    assert_not_nil invoice.id
  end

  test 'should create invoice with pdf' do
    @invoice.generation_json = @invoice.send(:generate_hash, @sale).to_json

    assert_difference('ActiveStorage::Attachment.count', 1) do
      @invoice.send(:create_invoice)
      @invoice.save!
    end

    assert_predicate @invoice.pdf, :attached?
  end

  test 'should set id if nil on create invoice' do
    @invoice.generation_json = @invoice.send(:generate_hash, @sale).to_json
    @invoice.id = nil
    @invoice.send(:create_invoice)
    assert_not_nil @invoice.id
  end

  test 'should not destroy invoice if sale exists' do
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      @invoice.destroy
    end
  end
end
