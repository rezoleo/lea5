# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    user = User.upsert_from_auth_hash(request.env['omniauth.auth'])
    redirect_to user_path user
  end
end
