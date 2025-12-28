# frozen_string_literal: true

require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  def setup
    super
    @client = users(:ironman)
    @sale = sales(:ironman_cable_6_months)
    @invoice = invoices(:sale_ironman_cable_6_months)
  end

  test 'should be valid' do
    assert_predicate @invoice, :valid?
  end

  test 'should generate correct user' do
    assert_equal @invoice.user, @client
  end

  test 'should generate correct hash' do
    invoice = Invoice.build_from_sale(@sale)

    expected_hash = {
      invoice_id: invoice.id,
      sale_date: Time.zone.today,
      issue_date: Time.zone.today,
      client_name: @sale.client.display_name,
      client_address: @sale.client.display_address,
      payment_amount: @sale.verified_at.nil? ? Money.new(0, :eur) : @sale.total_price,
      payment_method: @sale.payment_method.name,
      payment_date: @sale.verified_at,
      items: Invoice.send(:sales_items_to_h, @sale)
    }.compact

    # Round trip through JSON serialization
    # The expected_hash has Date objects for sale/issue_date, but the generation_json property has its values
    # converted by Rails to the types accepted by a JSON object (so the string representation of the date).
    expected = JSON.parse(expected_hash.to_json)
    assert_equal expected, invoice.generation_json
  end

  test 'should generate json and id from sale' do
    invoice = Invoice.build_from_sale(@sale)

    assert_not_nil invoice.generation_json
    assert_not_nil invoice.id
  end

  test 'should create invoice with pdf' do
    invoice = Invoice.build_from_sale(@sale)

    assert_difference('ActiveStorage::Attachment.count', 1) do
      invoice.save!
    end

    assert_predicate invoice.pdf, :attached?
  end

  test 'should not destroy invoice if sale exists' do
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      @invoice.destroy
    end
  end
end
