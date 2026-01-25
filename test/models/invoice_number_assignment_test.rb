# frozen_string_literal: true

require 'test_helper'

class InvoiceNumberAssignmentTest < ActiveSupport::TestCase
  def setup
    super
    @user = users(:ironman)
    @payment_method = payment_methods(:credit_card)
    reset_invoice_number_counter!
  end

  test 'invoice numbers should be assigned sequentially without gaps on successful sales' do
    sale1 = create_valid_sale
    sale2 = create_valid_sale
    sale3 = create_valid_sale

    assert_equal 1, sale1.invoice.number
    assert_equal 2, sale2.invoice.number
    assert_equal 3, sale3.invoice.number
  end

  test 'invoice number assignment should be atomic across concurrent requests' do
    sales = Array.new(5) { build_valid_sale }

    threads = sales.map do |sale|
      Thread.new { sale.save }
    end
    threads.each(&:join)

    invoice_numbers = sales.filter_map { |s| s.invoice&.number }.sort
    expected_numbers = (1..5).to_a

    assert_equal expected_numbers, invoice_numbers, 'Invoice numbers should be sequential without gaps'
  end

  test 'invoice number should be assigned even if PDF generation fails' do
    sale = build_valid_sale

    sale.invoice.define_singleton_method(:generate_pdf!) do
      raise StandardError, 'PDF generation error'
    end

    assert_raises(StandardError) { sale.save }

    assert_equal 1, sale.invoice.number

    valid_sale = create_valid_sale
    assert_equal 2, valid_sale.invoice.number
  end

  test 'next_invoice_number! should initialize counter to 1 if setting does not exist' do
    Setting.find_by(key: 'next_invoice_number')&.destroy

    result = Setting.next_invoice_number!

    assert_equal 1, result
  end

  private

  # :nocov:
  def reset_invoice_number_counter!
    setting = Setting.find_by(key: 'next_invoice_number')
    if setting
      setting.update!(value: 1)
    else
      Setting.create!(key: 'next_invoice_number', value: 1)
    end
  end
  # :nocov:

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
    assert sale.save, "Sale should be valid: #{sale.errors.full_messages.join(', ')}"
    sale
  end
end
