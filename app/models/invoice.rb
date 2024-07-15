# frozen_string_literal: true

class Invoice < ApplicationRecord
  has_one :sale, dependent: :restrict_with_exception
  has_one_attached :pdf

  before_create :create_invoice

  def user
    sale.client
  end

  private

  def create_invoice
    id = generate_invoice_id
    pdf.attach(io: InvoicePdfGenerator.new(JSON.parse(generation_json).deep_symbolize_keys).generate_pdf,
               filename: id, content_type: 'application/pdf')
  end

  def generate_invoice_id
    json = JSON.parse(generation_json).symbolize_keys
    json[:invoice_id] = Setting.next_invoice_id
    self.generation_json = json.to_json
  end
end
