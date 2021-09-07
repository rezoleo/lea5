# typed: true
# frozen_string_literal: true

class SeedsIps < ActiveRecord::Migration[6.0]
  def up
    require_relative '../seeds/ips'
  end

  def down
    Ip.delete_all
  end
end
