# frozen_string_literal: true

require 'ipaddr'

class SearchController < ApplicationController
  def search
    @query = params[:q]
    return if @query.blank?

    users = User.accessible_by(current_ability).search_by(@query)
                .includes(:valid_subscriptions_by_date, :free_accesses_by_date)
                .order(:lastname, :firstname, :id)

    machines = Machine.accessible_by(current_ability).search_by(@query)
                      .includes(:ip)
                      .order(:name, :id)

    @pagy_users, @users = pagy(users, page_key: 'users_page')
    @pagy_machines, @machines = pagy(machines, page_key: 'machines_page')

    return unless valid_ip?(@query)

    @ip = Ip.accessible_by(current_ability).includes(:machine).where.not(machine_id: nil).find_by(ip: @query)
  end

  private

  def valid_ip?(string)
    IPAddr.new(string).ipv4?
  rescue IPAddr::InvalidAddressError
    false
  end
end
