# frozen_string_literal: true

class RenameDurationToQuantityInSubscriptionOffersJoinTable < ActiveRecord::Migration[7.0]
  def change
    rename_column :sales_subscription_offers, :duration, :quantity
    rename_column :refunds_subscription_offers, :duration, :quantity
  end
end
