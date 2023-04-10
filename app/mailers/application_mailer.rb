# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@rezoleo.fr'
  layout 'mailer'
end
