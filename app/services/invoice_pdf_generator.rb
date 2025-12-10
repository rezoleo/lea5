# frozen_string_literal: true

require 'hexapdf'

class InvoiceLib
  FOOTER = <<~FOOTER
    Le délai de paiement est de 45 jours + fin du mois, à partir de la date de facturation (date d'émission de la facture).
    En cas de retard de paiement, seront exigibles, conformément à l'article L 441-6 du code de commerce, une indemnité calculée sur la base de trois fois le taux de l'intérêt légal en vigueur ainsi qu'une indemnité forfaitaire pour frais de recouvrement de 40 euros.
  FOOTER

  CONDITIONS = <<~CONDITIONS
    Conditions de règlement : Prix comptant sans escompte
    Moyen de paiement : Chèque (ordre : Rézoléo), Espèces ou Virement
    Conditions de vente : Prix de départ

    (1) TVA non applicable, article 293 B du CGI
  CONDITIONS

  INFO_REZOLEO = <<~INFOS
    École Centrale de Lille - Avenue Paul Langevin - 59650 Villeneuve d'Ascq
    rezoleo@rezoleo.fr
    SIRET : 831 134 804 00010
    IBAN : FR76 1670 6050 8753 9414 0728 132
  INFOS

  class PDFMetadata
    attr_reader :title, :author, :subject, :creation_date

    def initialize(invoice_id:)
      @title = "Facture Rézoléo #{invoice_id}"
      @author = 'Association Rézoléo'
      @subject = "Facture #{invoice_id}"
      @creation_date = Time.now.utc
    end
  end
end

class InvoicePdfGenerator
  BASE_FONT_SIZE = 12

  # @input should be a hash with the following keys:
  # - :invoice_id (String) - ID of the invoice
  # - :sale_date (String) - Date of sale
  # - :issue_date (String) - Date the invoice was issued
  # - :client_name (String) - Name of the client
  # - :client_address (String) - Address of the client
  # - :items (Array of Hashes) - List of items, each item being a hash with keys:
  #   - :item_name (String) - Name of the item
  #   - :price (Money) - Price of the item as a Money object
  #   - :quantity (Integer) - Quantity of the item
  # - :payment_amount (Money, optional) - Amount already paid as a Money object
  # - :payment_date (String, optional) - Date of payment
  # - :payment_method (String, optional) - Method of payment
  def initialize(input)
    @input = input
    @doc_metadata = InvoiceLib::PDFMetadata.new(invoice_id: input[:invoice_id])
    @total_price = input[:items].sum { |item| to_money(item[:price]) * item[:quantity] }
    @composer = InvoiceComposer.new
    setup_document
  end

  # @return [StringIO] A stream containing the generated PDF file data
  def generate_pdf
    add_invoice_header
    add_client_info
    add_items_table
    add_totals
    add_payment_info

    # return the result directly as a file stream
    pdf_stream = StringIO.new
    @composer.write(pdf_stream)
    pdf_stream.rewind
    pdf_stream
  end

  private

  def setup_document
    @composer.document.metadata.title(@doc_metadata.title)
    @composer.document.metadata.author(@doc_metadata.author)
    @composer.document.metadata.subject(@doc_metadata.subject)
    @composer.document.metadata.creation_date(@doc_metadata.creation_date)
  end

  def add_invoice_header
    invoice_header = <<~HEADER
      Facture n°#{@input[:invoice_id]}
      Date de vente : #{@input[:sale_date]}
      Date d'émission : #{@input[:issue_date]}
    HEADER

    @composer.text(invoice_header, style: :base, text_align: :center, margin: margin_bottom(2))
    @composer.text('Association Rézoléo (Trésorerie)', style: :bold, margin: margin_bottom(1))
    @composer.text(InvoiceLib::INFO_REZOLEO, margin: margin_bottom(2))
  end

  def add_client_info
    @composer.text('Client', style: :bold, margin: margin_bottom(1))
    @composer.text(@input[:client_name], margin: margin_bottom(1))
    @composer.text(@input[:client_address], margin: margin_bottom(3))
  end

  def add_items_table
    data = @input[:items].each_with_index.map { |item, i| build_item_row(item, i + 1) }
    data << build_total_row

    @composer.table(data, column_widths: [-1, -9, -3, -2, -2, -3], header: items_table_header, margin: margin_bottom(2))
  end

  def items_table_header
    lambda do |_tb|
      [
        { background_color: 'C0C0C0' },
        [
          table('ID', style: :small),
          table('Désignation article', style: :small),
          table('Prix unit. HT', style: :small, text_align: :right),
          table('Quantité', style: :small, text_align: :right),
          table('TVA (1)', style: :small, text_align: :right),
          table('Total TTC', style: :small, text_align: :right)
        ]
      ]
    end
  end

  def build_item_row(item, item_id)
    price = to_money(item[:price])
    quantity = item[:quantity]

    [
      item_id.to_s,
      item[:item_name],
      table(format_money(price), text_align: :right),
      table(quantity.to_s, text_align: :right),
      table('0%', text_align: :right),
      table(format_money(price * quantity), text_align: :right)
    ]
  end

  def build_total_row
    [
      { content: 'Total', col_span: 5 },
      table(format_money(@total_price), text_align: :right)
    ]
  end

  def add_totals
    ht_s = "Somme totale hors taxes (en euros, HT) : #{format_money(@total_price)}"
    ttc_s = "Somme totale à payer toutes taxes comprises (en euros, TTC) : #{format_money(@total_price)}"

    @composer.text(ht_s)
    @composer.text(ttc_s, margin: margin_bottom(1))
    @composer.text(InvoiceLib::CONDITIONS, style: :conditions, margin: margin_bottom(3))
  end

  def add_payment_info
    header = lambda do |_tb|
      [{ background_color: 'C0C0C0' },
       [
         table('Date', style: :small),
         table('Règlement', style: :small),
         table('Montant', style: :small, text_align: :right),
         table('À payer', style: :small, text_align: :right)
       ]]
    end

    payment_amount = to_money(@input[:payment_amount] || Money.new(0, 'EUR'))
    left_to_pay = @total_price - payment_amount

    data = [[
      table(@input[:payment_date] || '', style: :small),
      table(@input[:payment_method] || '', style: :small),
      table(format_money(payment_amount), style: :small, text_align: :right),
      table(format_money(left_to_pay), style: :small, text_align: :right)
    ]]

    @composer.table(data, column_widths: [-3, -5, -2, -2], header: header, width: 300)
  end

  def margin_bottom(lines)
    [0, 0, lines * BASE_FONT_SIZE]
  end

  def to_money(value)
    return value if value.is_a?(Money)
    return Money.new(value['cents'], value['currency_iso']) if value.is_a?(Hash)

    value
  end

  def format_money(money)
    money.format(format: '%n%u')
  end

  def table(text, style: :base, text_align: :left)
    @composer.document.layout.text(text, style: style, text_align: text_align)
  end

  class InvoiceComposer < HexaPDF::Composer
    def initialize(page_size: :A4, page_orientation: :portrait, margin: 36)
      super

      document.task(:pdfa)
    end

    def new_page
      super

      config_font(font_name: 'DejaVu Sans',
                  font_file: Rails.root.join('app/assets/fonts/DejaVuSans.ttf').to_s,
                  bold_font_file: Rails.root.join('app/assets/fonts/DejaVuSans-Bold.ttf').to_s)

      config_font_style(font: 'DejaVu Sans')

      image(Rails.root.join('app/assets/images/rezoleo_logo.png').to_s, width: 75, position: :float, mask_mode: :none)
      text('Facture Rézoléo', style: :header, margin: [0, 0, 2 * BASE_FONT_SIZE])
      text(InvoiceLib::FOOTER, style: :footer, position: [0, 0])
    end

    private

    def config_font(font_name:, font_file:, bold_font_file:)
      document.config['font.map'] = {
        font_name.to_s => {
          none: font_file.to_s,
          bold: bold_font_file.to_s
        }
      }
    end

    def config_font_style(font:)
      styles(
        base: { font: font, font_size: BASE_FONT_SIZE, line_spacing: 1.2 },
        bold: { font: [font, { variant: :bold }] },
        header: { font: [font, { variant: :bold }], font_size: BASE_FONT_SIZE * 7 / 6, text_align: :center },
        footer: { font: font, font_size: BASE_FONT_SIZE / 2, text_align: :center },
        small: { font: font, font_size: BASE_FONT_SIZE * 0.75 },
        conditions: { font: font, font_size: BASE_FONT_SIZE * 5 / 6, fill_color: '3C3C3C' }
      )
    end
  end
end
