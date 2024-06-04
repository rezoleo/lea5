# frozen_string_literal: true

class SearchController < ApplicationController
  VALID_IP_REGEX = /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$/i
  def search
    @query = params[:q]
    @users = User.accessible_by(current_ability).where(
      'firstname ILIKE :search OR lastname ILIKE :search OR email ILIKE :search OR room ILIKE :search',
      search: "%#{User.sanitize_sql_like @query}%"
    )
    @machines = Machine.accessible_by(current_ability).where(
      'name ILIKE :search OR CAST(mac as varchar) ILIKE :search',
      search: "%#{Machine.sanitize_sql_like @query}%"
    )
    return unless @query.match?(VALID_IP_REGEX)

    @ip = Ip.accessible_by(current_ability).where(ip: @query).includes(:machine).first
  end
end
