# frozen_string_literal: true

# It is recommended to instantiate a new invoice from a sale, using {Invoice.build_from_sale}
class Invoice < ApplicationRecord
  has_one :sale, dependent: :restrict_with_exception
  has_one_attached :pdf

  before_validation :assign_number!
  after_create_commit :generate_pdf!

  # @return [User]
  def user
    sale.client
  end

  # @param [Sale] sale
  # @return [Invoice]
  def self.build_from_sale(sale)
    generation_json = generate_hash(sale)

    new do |invoice|
      invoice.generation_json = generation_json
    end
  end

  # @return [Integer] the assigned invoice number
  def assign_number!
    return number if number.present?

    new_invoice_number = Setting.next_invoice_number!
    self.number = new_invoice_number
    new_invoice_number
  end

  def generate_pdf!
    raise 'Invoice must have a number before generating PDF' if number.nil?
    return if pdf.attached?

    pdf_data = generation_json.deep_symbolize_keys.merge(number: number)
    pdf_stream = InvoicePdfGenerator.new(pdf_data).generate_pdf
    pdf.attach(io: pdf_stream, filename: number.to_s, content_type: 'application/pdf')
  end

  class << self
    private

    # @param [Sale] sale
    def generate_hash(sale)
      {
        # Is it possible to use sale.created_at.to_date here?
        # The sale record has not yet been created so the value isn't populated.
        version: 1, # invoice json version
        sale_date: Time.zone.today,
        issue_date: Time.zone.today,
        client_name: sale.client.display_name,
        client_address: sale.client.display_address,
        payment_amount: sale.verified_at.nil? ? Money.new(0) : sale.total_price,
        payment_method: sale.payment_method&.name,
        payment_date: sale.verified_at,
        items: sales_items_to_h(sale)
      }.compact
    end

    # @param [Sale] sale
    # @return [Array<Hash{Symbol=>String, Money, Integer}>]
    def sales_items_to_h(sale)
      sale_articles_to_h(sale) + sale_subscription_offers_to_h(sale)
    end

    # @param [Sale] sale
    # @return [Array<Hash{Symbol=>String, Money, Integer}>]
    def sale_articles_to_h(sale)
      sale.articles_sales.map do |e|
        {
          item_name: e.article.name,
          price: e.article.price,
          quantity: e.quantity
        }
      end
    end

    # @param [Sale] sale
    # @return [Array<Hash{Symbol=>String, Money, Integer}>]
    def sale_subscription_offers_to_h(sale)
      sale.sales_subscription_offers.map do |e|
        {
          item_name: "Abonnement - #{e.subscription_offer.duration} mois",
          price: e.subscription_offer.price,
          quantity: e.quantity
        }
      end
    end
  end
end
