# frozen_string_literal: true

class Invoice < ApplicationRecord
  has_one :sale, dependent: :restrict_with_exception
  has_one_attached :pdf
  def user
    sale.client
  end

  def generate
    InvoicePdfGenerator.new(JSON.parse(generation_json).deep_symbolize_keys).generate_pdf
  end
end
