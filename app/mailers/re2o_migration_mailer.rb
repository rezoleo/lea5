# frozen_string_literal: true

class Re2oMigrationMailer < ApplicationMailer
  def claim_link
    @account = params[:account]
    @url = link_migration_url(token: params[:token])
    mail(to: @account.email, subject: 'Rézoléo: migrate your re2o account')
  end
end
