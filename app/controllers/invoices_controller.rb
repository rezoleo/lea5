# frozen_string_literal: true

class InvoicesController < ApplicationController
  def download
    @invoice = Invoice.find_by!(number: params[:number])
    authorize! :read, @invoice

    send_data @invoice.pdf.download, filename: @invoice.pdf.filename.to_s, type: 'application/pdf'
  end
end
