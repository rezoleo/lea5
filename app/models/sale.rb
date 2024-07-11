# frozen_string_literal: true

class Sale < ApplicationRecord
  belongs_to :seller, class_name: 'User', optional: true
  belongs_to :client, class_name: 'User'
  belongs_to :payment_method
  belongs_to :invoice
  has_one :subscription, dependent: :destroy
  has_many :refunds, dependent: :destroy
  has_many :articles_sales, dependent: :destroy
  has_many :articles, through: :articles_sales
  has_many :sales_subscription_offers, dependent: :destroy
  has_many :subscription_offers, through: :sales_subscription_offers

  accepts_nested_attributes_for :articles_sales
  accepts_nested_attributes_for :sales_subscription_offers

  validates :total_price, presence: true

  def verify
    self.verified_at = Time.zone.now if verified_at.nil?
  end

  def update_total_price
    total = 0
    articles_sales.each do |rec|
      total += rec.quantity * Article.find(rec.article_id).price
    end
    sales_subscription_offers.each do |rec|
      total += rec.quantity * SubscriptionOffer.find(rec.subscription_offer.id).price
    end
    self.total_price = total
  end

  def gen_temp_invoice
    return if invoice

    self.invoice = Invoice.new(generation_json: global_invoice_hash.to_json)
  end

  def generate_invoice_id
    hash = JSON.parse(invoice.generation_json).symbolize_keys
    return unless hash[:invoice_id].nil?

    hash[:invoice_id] = "F-#{invoice.id}"
    self.invoice = Invoice.new(generation_json: hash.to_json)
    hash[:invoice_id]
  end

  private

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def global_invoice_hash
    hash = {
      sale_date: Time.zone.today,
      issue_date: Time.zone.today,
      client_name: "#{client.firstname.capitalize} #{client.lastname.upcase}",
      client_address: "Appartement #{client.room}\nRésidence Léonard de Vinci
                        Avenue Paul Langevin\n59650 Villeneuve-d'Ascq",
      payment_amount_cent: verified_at.nil? ? 0 : total_price,
      payment_method: payment_method.name
    }
    hash[:payment_date] = verified_at unless verified_at.nil?
    hash[:items] = []
    sales_subscription_offers.each do |e|
      item_hash = { item_name: "Abonnement - #{e.subscription_offer.duration} mois",
                    price_cents: e.subscription_offer.price, quantity: e.quantity }
      hash[:items].push item_hash
    end
    articles_sales.each do |e|
      item_hash = { item_name: e.article.name,
                    price_cents: e.article.price, quantity: e.quantity }
      hash[:items].push item_hash
    end
    hash
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
