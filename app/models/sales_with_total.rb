# frozen_string_literal: true

class SalesWithTotal < ApplicationRecord
  self.primary_key = :id


  belongs_to :client, class_name: 'User', foreign_key: :client_id
  belongs_to :seller, class_name: 'User', foreign_key: :seller_id, optional: true
  belongs_to :payment_method
  attribute :total_cents

  def readonly?
    true
  end

  def total_price
    Money.new(total_cents)
  end

  def articles_total
    Money.new(articles_total_cents)
  end

  def subscriptions_total
    Money.new(subscriptions_total_cents)
  end
end
