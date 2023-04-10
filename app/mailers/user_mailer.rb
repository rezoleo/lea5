# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default from: email_address_with_name('no-reply@rezoleo.fr', 'Lea5')

  def internet_expiration_7_days
    @user = params[:user]
    mail(to: email_address_with_name(@user.email, "#{@user.firstname} #{@user.lastname}"),
         subject: 'Your internet will expire in 7 days')
  end

  def internet_expiration_1_day
    @user = params[:user]
    mail(to: email_address_with_name(@user.email, "#{@user.firstname} #{@user.lastname}"),
         subject: 'Your internet will expire tomorrow')
  end
end
