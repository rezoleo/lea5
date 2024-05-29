# frozen_string_literal: true

class SearchController < ApplicationController
  def search
    @query = params[:q]
    @users = User.where(
      'firstname ILIKE :search OR lastname ILIKE :search OR email ILIKE :search OR room ILIKE :search',
      search: "%#{User.sanitize_sql_like @query}%"
    )
    @machines = Machine.where(
      'name ILIKE :search OR CAST(mac as varchar) ILIKE :search',
      search: "%#{Machine.sanitize_sql_like @query}%"
    )
    @ip = Ip.where(ip: @query).includes(:machine).first
  end
end
