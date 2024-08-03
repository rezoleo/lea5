# frozen_string_literal: true

class Invoice < ApplicationRecord
  has_one :sale, dependent: :restrict_with_exception
  has_one_attached :pdf

  before_create :create_invoice

  def user
    sale.client
  end

  def generate_from(sale)
    self.generation_json = generate_hash(sale).to_json if generation_json.nil?
    self.id = generate_invoice_id if id.nil?
  end

  private

  def create_invoice
    self.id = generate_invoice_id if id.nil?
    pdf_stream = InvoicePdfGenerator.new(JSON.parse(generation_json).deep_symbolize_keys).generate_pdf
    pdf.attach(io: pdf_stream, filename: id, content_type: 'application/pdf')
  end

  def generate_invoice_id
    json = JSON.parse(generation_json).symbolize_keys
    json[:invoice_id] = Setting.next_invoice_id
    self.generation_json = json.to_json
  end

  def generate_hash(sale)
    {
      sale_date: Time.zone.today,
      issue_date: Time.zone.today,
      client_name: sale.client.display_name,
      client_address: sale.client.display_address,
      payment_amount_cent: sale.verified_at.nil? ? 0 : sale.total_price,
      payment_method: sale.payment_method&.name,
      payment_date: sale.verified_at,
      items: sales_itemized(sale)
    }.compact
  end

  def sales_itemized(sale)
    articles_itemized(sale) + subscriptions_offers_itemized(sale)
  end

  def articles_itemized(sale)
    sale.articles_sales.map do |e|
      {
        item_name: e.article.name,
        price_cents: e.article.price,
        quantity: e.quantity
      }
    end
  end

  def subscriptions_offers_itemized(sale)
    sale.sales_subscription_offers.map do |e|
      {
        item_name: "Abonnement - #{e.subscription_offer.duration} mois",
        price_cents: e.subscription_offer.price,
        quantity: e.quantity
      }
    end
  end
end
