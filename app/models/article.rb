# frozen_string_literal: true

class Article < ApplicationRecord
  has_many :articles_sales, dependent: :restrict_with_error
  has_many :sales, through: :articles_sales
  has_many :articles_refunds, dependent: :restrict_with_error
  has_many :refunds, through: :articles_refunds

  validates :name, presence: true, allow_blank: false
  validates :price, presence: true, allow_blank: false,
                    numericality: { greater_than: 0, only_integer: true, message: 'Must be a positive
                     number. Maximum 2 numbers after comma' }

  default_scope { where(deleted_at: nil) }

  def soft_delete
    update(deleted_at: Time.zone.now) if deleted_at.nil?
  end
end
