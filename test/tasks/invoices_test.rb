# frozen_string_literal: true

require 'rake'
require 'test_helper'

class InvoicesTaskTest < ActiveSupport::TestCase
  def setup
    super
    Rake.application.rake_require 'tasks/invoices'
    Rake::Task.define_task(:environment)
  end

  test 'generates only the missing invoice PDFs' do
    invoice = invoices(:sale_pepper_1_year)
    invoice.pdf_attachment.delete
    untouched = invoices(:sale_ironman_cable_6_months).pdf.blob

    assert_output(/^Generated invoice #{invoice.number}$/) do
      Rake::Task['lea5:generate_missing_invoice_pdfs'].invoke
    end

    assert_predicate invoice.reload.pdf, :attached?
    assert_equal untouched, invoices(:sale_ironman_cable_6_months).pdf.blob
  end
end
