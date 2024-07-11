# frozen_string_literal: true

class Invoice < ApplicationRecord
  def generate
    InvoicePdfGenerator.new(JSON.parse(generation_json).deep_symbolize_keys).generate_pdf
  end
end
