# frozen_string_literal: true

# It is recommended to instantiate a new invoice from a sale, using {Invoice.build_from_sale}
class Invoice < ApplicationRecord
  has_one :sale, dependent: :restrict_with_exception
  has_one_attached :pdf

  before_create :create_invoice

  # @return [User]
  def user
    sale.client
  end

  # @param [Sale] sale
  # @return [Invoice]
  def self.build_from_sale(sale)
    generation_json = generate_hash(sale)
    invoice_id = Setting.next_invoice_id!
    generation_json[:invoice_id] = invoice_id

    new do |invoice|
      invoice.generation_json = generation_json
      invoice.id = invoice_id
    end
  end

  private

  def create_invoice
    pdf_stream = InvoicePdfGenerator.new(generation_json.deep_symbolize_keys).generate_pdf
    pdf.attach(io: pdf_stream, filename: id, content_type: 'application/pdf')
  end

  class << self
    private

    # @param [Sale] sale
    def generate_hash(sale)
      {
        # Is it possible to use sale.created_at.to_date here?
        # The sale record has not yet been created so the value isn't populated.
        sale_date: Time.zone.today,
        issue_date: Time.zone.today,
        client_name: sale.client.display_name,
        client_address: sale.client.display_address,
        payment_amount_cent: sale.verified_at.nil? ? 0 : sale.total_price,
        payment_method: sale.payment_method&.name,
        payment_date: sale.verified_at,
        items: sales_items_to_h(sale)
      }.compact
    end

    # @param [Sale] sale
    # @return [Array<Hash{Symbol=>String, Integer}>]
    def sales_items_to_h(sale)
      sale_articles_to_h(sale) + sale_subscription_offers_to_h(sale)
    end

    # @param [Sale] sale
    # @return [Array<Hash{Symbol=>String, Integer}>]
    def sale_articles_to_h(sale)
      sale.articles_sales.map do |e|
        {
          item_name: e.article.name,
          price_cents: e.article.price,
          quantity: e.quantity
        }
      end
    end

    # @param [Sale] sale
    # @return [Array<Hash{Symbol=>String, Integer}>]
    def sale_subscription_offers_to_h(sale)
      sale.sales_subscription_offers.map do |e|
        {
          item_name: "Abonnement - #{e.subscription_offer.duration} mois",
          price_cents: e.subscription_offer.price,
          quantity: e.quantity
        }
      end
    end
  end
end
