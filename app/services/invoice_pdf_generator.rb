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
      @creation_date = Time.now # rubocop:disable Rails/TimeZone
    end
  end
end

# rubocop:disable Metrics/ClassLength
class InvoicePdfGenerator
  BASE_FONT_SIZE = 12

  def initialize(input)
    @input = input
    @doc_metadata = InvoiceLib::PDFMetadata.new(invoice_id: input[:invoice_id])
    @total_price_in_cents = input[:items].sum { |it| it[:price_cents] * it[:quantity] }
    @composer = InvoiceComposer.new(skip_page_creation: true)
    setup_document
  end

  def generate_pdf
    @composer.new_page
    add_invoice_header
    add_client_info
    add_items_table
    add_totals
    add_payment_info

    file_path = Rails.root.join('tmp', "FE_#{@input[:invoice_id]}.pdf").to_s
    @composer.write(file_path)
    file_path
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

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def add_items_table
    header = lambda do |_tb|
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

    data = @input[:items].each_with_index.map do |item, i|
      item_id = i + 1
      item_name = item[:item_name]
      price_in_cents = item[:price_cents]
      quantity = item[:quantity]

      [
        item_id.to_s,
        item_name,
        table(format_cents(price_in_cents), text_align: :right),
        table(quantity.to_s, text_align: :right),
        table('0%', text_align: :right),
        table(format_cents(price_in_cents * quantity), text_align: :right)
      ]
    end

    data << [
      { content: 'Total', col_span: 5 },
      table(format_cents(@total_price_in_cents), text_align: :right)
    ]

    @composer.table(data, column_widths: [-1, -9, -3, -2, -2, -3], header: header, margin: margin_bottom(2))
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def add_totals
    ht_s = "Somme totale hors taxes (en euros, HT) : #{format_cents(@total_price_in_cents)}"
    ttc_s = "Somme totale à payer toutes taxes comprises (en euros, TTC) : #{format_cents(@total_price_in_cents)}"

    @composer.text(ht_s)
    @composer.text(ttc_s, margin: margin_bottom(1))
    @composer.text(InvoiceLib::CONDITIONS, style: :conditions, margin: margin_bottom(3))
  end

  def add_payment_info
    header = lambda do |_tb|
      [{ background_color: 'C0C0C0' },
       [
         table('Date', style: :small), table('Règlement', style: :small),
         table('Montant', style: :small, text_align: :right), table('À payer', style: :small, text_align: :right)
       ]]
    end

    payed_in_cents = @input[:payment_amount_cents] || 0
    left_to_pay_in_cents = @total_price_in_cents - payed_in_cents

    data = [[
      table(@input[:payment_date] || '', style: :small), table(@input[:payment_method] || '', style: :small),
      table(format_cents(payed_in_cents), style: :small, text_align: :right),
      table(format_cents(left_to_pay_in_cents), style: :small, text_align: :right)
    ]]

    @composer.table(data, column_widths: [-3, -5, -2, -2], header: header, width: 300)
  end

  def margin_bottom(lines)
    [0, 0, lines * BASE_FONT_SIZE]
  end

  def format_cents(cents)
    "#{format('%.2f', cents.to_f / 100)}€"
  end

  def table(text, style: :base, text_align: :left)
    @composer.document.layout.text(text, style: style, text_align: text_align)
  end

  class InvoiceComposer < HexaPDF::Composer
    def initialize(skip_page_creation: false, page_size: :A4, page_orientation: :portrait, margin: 36)
      super

      document.task(:pdfa)
      config_font(font_name: 'DejaVu Sans',
                  font_file: Rails.root.join('app/assets/fonts/DejaVuSans.ttf').to_s,
                  bold_font_file: Rails.root.join('app/assets/fonts/DejaVuSans-Bold.ttf').to_s)
      config_style(font: 'DejaVu Sans', page_size: page_size)
    end

    def new_page(style = @next_page_style)
      super

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

    def config_style(font:, page_size:)
      style(:base, font: font, font_size: BASE_FONT_SIZE, line_spacing: 1.2)
      style(:bold, font: [font, { variant: :bold }])
      style(:header, font: [font, { variant: :bold }], font_size: BASE_FONT_SIZE * 7 / 6, text_align: :center)
      style(:footer, font: font, font_size: BASE_FONT_SIZE / 2, text_align: :center)
      style(:small, font: font, font_size: BASE_FONT_SIZE * 0.75)
      style(:conditions, font: font, font_size: BASE_FONT_SIZE * 5 / 6, fill_color: '3C3C3C')
      page_style(:default, page_size:)
    end
  end
end
# rubocop:enable Metrics/ClassLength
