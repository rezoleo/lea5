# frozen_string_literal: true

require 'test_helper'

class InvoiceIdAssignmentTest < ActiveSupport::TestCase
  def setup
    super
    @user = users(:ironman)
    @payment_method = payment_methods(:credit_card)
    @article = articles(:cable)
    Setting.destroy_all
  end

  test 'invoice IDs should be assigned sequentially without gaps on successful sales' do
    sale1 = create_valid_sale
    sale2 = create_valid_sale
    sale3 = create_valid_sale

    assert_equal 1, sale1.invoice.invoice_id
    assert_equal 2, sale2.invoice.invoice_id
    assert_equal 3, sale3.invoice.invoice_id
  end

  test 'invoice ID should not be assigned if sale validation fails' do
    sale = Sale.build_with_invoice(
      {
        client: @user,
        duration: 0,
        payment_method: @payment_method
        # Missing articles/subscriptions - will be invalid
      },
      seller: @user
    )

    assert_not sale.save_with_invoice
    assert_nil sale.invoice&.invoice_id

    # Next valid sale should get ID 1
    valid_sale = create_valid_sale
    assert_equal 1, valid_sale.invoice.invoice_id
  end

  test 'invoice ID should not be assigned if invoice validation fails' do
    sale = Sale.build_with_invoice(
      {
        client: @user,
        duration: 1,
        payment_method: @payment_method
      },
      seller: @user
    )

    sale.invoice.define_singleton_method(:valid?) { false }

    assert_not sale.save_with_invoice
    assert_nil sale.invoice.invoice_id

    # Next valid sale should get ID 1
    valid_sale = create_valid_sale
    assert_equal 1, valid_sale.invoice.invoice_id
  end

  test 'invoice ID assignment should be atomic across concurrent requests' do
    sales = Array.new(5) { build_valid_sale }

    # Simulate concurrent saves
    threads = sales.map do |sale|
      Thread.new { sale.save_with_invoice }
    end
    threads.each(&:join)

    invoice_ids = sales.filter_map { |s| s.invoice&.invoice_id }.sort
    expected_ids = (1..5).to_a

    assert_equal expected_ids, invoice_ids, 'Invoice IDs should be sequential without gaps'
  end

  test 'invoice ID should be assigned even if PDF generation fails' do
    sale = build_valid_sale

    sale.invoice.define_singleton_method(:generate_pdf!) do
      raise StandardError, 'PDF generation error'
    end

    assert_raises(StandardError) { sale.save_with_invoice }

    # Invoice should still have an ID assigned
    assert_not_nil sale.invoice.invoice_id
    assert_equal 1, sale.invoice.invoice_id

    # Next sale should get the next sequential ID
    valid_sale = create_valid_sale
    assert_equal 2, valid_sale.invoice.invoice_id
  end

  test 'invoice ID should not be consumed if transaction rolls back before ID assignment' do
    sale = build_valid_sale

    # Force a rollback in the first transaction by making save! fail
    sale.define_singleton_method(:save!) do
      raise ActiveRecord::RecordInvalid, sale
    end

    assert_not sale.save_with_invoice
    assert_nil sale.invoice.invoice_id

    # Next valid sale should get ID 1 (no ID was consumed)
    valid_sale = create_valid_sale
    assert_equal 1, valid_sale.invoice.invoice_id
  end

  test 'assign_invoice_id! should raise error if invoice not persisted' do
    invoice = Invoice.new(generation_json: { test: 'data' })

    error = assert_raises(RuntimeError) do
      invoice.assign_invoice_id!
    end

    assert_equal 'Invoice must be persisted before assigning invoice_id', error.message
  end

  test 'assign_invoice_id! should update invoice_id column and persist to database' do
    invoice = Invoice.create!(generation_json: { test: 'data' })

    returned_id = invoice.assign_invoice_id!

    assert_equal 1, returned_id
    assert_equal 1, invoice.invoice_id
    assert_equal 1, invoice.reload.invoice_id
  end

  test 'generation_json should not contain invoice_id after invoice creation' do
    sale = build_valid_sale
    sale.save_with_invoice

    assert_not sale.invoice.generation_json.key?('invoice_id')
    assert_not sale.invoice.generation_json.key?(:invoice_id)
  end

  test 'multiple failed sales should not consume invoice IDs' do
    5.times do
      sale = Sale.build_with_invoice(
        {
          client: @user,
          duration: 0,
          payment_method: @payment_method
          # Invalid: empty sale
        },
        seller: @user
      )
      assert_not sale.save_with_invoice
    end

    # First successful sale should get ID 1
    valid_sale = create_valid_sale
    assert_equal 1, valid_sale.invoice.invoice_id
  end

  test 'invoice_id should be unique across all invoices' do
    sale = create_valid_sale

    # Try to manually set duplicate invoice_id
    another_invoice = Invoice.create!(generation_json: { test: 'data' })
    another_invoice.invoice_id = sale.invoice.invoice_id

    assert_raises(ActiveRecord::RecordNotUnique) do
      another_invoice.save!
    end
  end

  test 'save_with_invoice should return false if invoice already has invoice_id' do
    sale = create_valid_sale

    # Try to save again
    result = sale.save_with_invoice

    assert_not result
    assert_equal 1, sale.invoice.invoice_id # ID should not change
  end

  private

  def build_valid_sale
    Sale.build_with_invoice(
      {
        client: @user,
        duration: 1,
        payment_method: @payment_method
      },
      seller: @user
    )
  end

  def create_valid_sale
    sale = build_valid_sale
    assert sale.save_with_invoice, "Sale should be valid: #{sale.errors.full_messages.join(', ')}"
    sale
  end
end
