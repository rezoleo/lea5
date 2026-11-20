# frozen_string_literal: true

namespace :lea5 do
  desc 'Generate the PDF of invoices that have none (e.g. after a failed generation)'
  task generate_missing_invoice_pdfs: :environment do
    Invoice.where.missing(:pdf_attachment).find_each do |invoice|
      invoice.generate_pdf!
      puts "Generated invoice #{invoice.number}"
    rescue StandardError => e
      puts "Failed invoice #{invoice.number}: #{e.message}"
    end
  end
end
