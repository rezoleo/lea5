# frozen_string_literal: true

require 'test_helper'

class InvoicePdfGeneratorTest < ActiveSupport::TestCase
  def setup
    super
    # Freeze time during setup and not just around the test, because the
    # InvoicePdfGenerator initialization captures the current time
    freeze_time

    @id = '4269'
    input = {
      invoice_id: @id,
      sale_date: '2024-07-21',
      issue_date: '2024-07-22',
      client_name: users(:ironman).display_name,
      client_address: users(:ironman).display_address,
      items: [
        { item_name: 'Article 1', price: Money.new(1000, 'EUR'), quantity: 2 },
        { item_name: 'Article 2', price: Money.new(500, 'EUR'), quantity: 3 }
      ],
      payment_amount: Money.new(2500, 'EUR'),
      payment_date: '2024-07-21',
      payment_method: 'Carte Bancaire'
    }
    @generator = InvoicePdfGenerator.new(input)
  end

  def teardown
    unfreeze_time
    super
  end

  test 'generate_pdf should return a StringIO object' do
    pdf = @generator.generate_pdf
    assert_instance_of StringIO, pdf
  end

  test 'generate_pdf should generate a valid PDF file' do
    pdf = @generator.generate_pdf
    assert_nothing_raised do
      HexaPDF::Document.new(io: pdf)
    end
  end

  test 'generate_pdf should include invoice header' do
    pdf = @generator.generate_pdf
    pdf_text = extract_text_from_pdf(pdf)
    assert_includes pdf_text, 'Facture Rézoléo'
    assert_includes pdf_text, '2024-07-21'
    assert_includes pdf_text, '2024-07-22'
  end

  test 'generate_pdf should include client information' do
    pdf = @generator.generate_pdf
    pdf_text = extract_text_from_pdf(pdf)
    assert_includes pdf_text, users(:ironman).display_name
    users(:ironman).display_address.split("\n").each do |address_line|
      assert_includes pdf_text, address_line
    end
  end

  test 'generate_pdf should include items table' do
    pdf = @generator.generate_pdf
    pdf_text = extract_text_from_pdf(pdf)
    assert_includes pdf_text, 'Article 1'
    assert_includes pdf_text, 'Article 2'
    assert_includes pdf_text, '2'
    assert_includes pdf_text, '3'
    assert_includes pdf_text, '10,00 €'
    assert_includes pdf_text, '5,00 €'
  end

  test 'generate_pdf should include total' do
    pdf = @generator.generate_pdf
    pdf_text = extract_text_from_pdf(pdf)
    assert_includes pdf_text, '35,00 €'
  end

  test 'generate_pdf should include payment information' do
    pdf = @generator.generate_pdf
    pdf_text = extract_text_from_pdf(pdf)
    assert_includes pdf_text, '25,00 €'
    assert_includes pdf_text, '2024-07-21'
    assert_includes pdf_text, 'Carte Bancaire'
  end

  test 'generate_pdf should include correct metadata' do
    pdf = @generator.generate_pdf
    metadata = extract_metadata_from_pdf(pdf)

    assert_equal "Facture Rézoléo #{@id}", metadata[:Title]
    assert_equal 'Association Rézoléo', metadata[:Author]
    assert_equal "Facture #{@id}", metadata[:Subject]
    assert_equal Time.current.utc, metadata[:CreationDate]
  end

  class CollectTextProcessor < HexaPDF::Content::Processor
    def initialize(page, content)
      super()
      @canvas = page.canvas(type: :overlay)
      @content = content
    end

    def show_text(str)
      boxes = decode_text_with_positioning(str)
      @content << boxes.string unless boxes.string.nil?
    end
    alias show_text_with_positioning show_text
  end

  def extract_text_from_pdf(pdf)
    doc = HexaPDF::Document.new(io: pdf)
    content = []

    doc.pages.each do |page|
      processor = CollectTextProcessor.new(page, content)
      page.process_contents(processor)
    end

    content.join
  end

  def extract_metadata_from_pdf(pdf)
    doc = HexaPDF::Document.new(io: pdf)
    doc.trailer.info
  end
end
