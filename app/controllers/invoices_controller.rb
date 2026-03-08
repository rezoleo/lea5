# frozen_string_literal: true

class InvoicesController < ApplicationController
  def download
    @invoice = Invoice.find_by!(number: params[:number])
    authorize! :read, @invoice

    redirect_to rails_blob_path(@invoice.pdf, disposition: 'attachment')
  end
end
