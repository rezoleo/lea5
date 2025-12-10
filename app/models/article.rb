# frozen_string_literal: true

class Article < ApplicationRecord
  has_many :articles_sales, dependent: :restrict_with_error
  has_many :sales, through: :articles_sales
  has_many :articles_refunds, dependent: :restrict_with_error
  has_many :refunds, through: :articles_refunds

  monetize :price_cents, as: :price, allow_nil: false, numericality: { greater_than: 0 }

  validates :name, presence: true, allow_blank: false

  scope :sellable, -> { where(deleted_at: nil) }

  def soft_delete
    update(deleted_at: Time.zone.now) if deleted_at.nil?
  end
end
