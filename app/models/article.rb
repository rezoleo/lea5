# frozen_string_literal: true

class Article < ApplicationRecord
  has_many :articles_sales, dependent: :restrict_with_exception
  has_many :sales, through: :articles_sales
  has_many :articles_refunds, dependent: :restrict_with_exception
  has_many :refunds, through: :articles_refunds

  validates :name, presence: true, allow_blank: false
  validates :price, presence: true, allow_blank: false,
                    numericality: { greater_than_or_equal_to: 0, only_integer: true }

  before_destroy :can_be_destroyed?

  def soft_delete!
    update(deleted_at: Time.zone.now)
  end

  def can_be_destroyed?
    return true if sales.empty?

    errors.add(:base, 'Cannot delete a sold article !')
    throw(:abort)
  end
end
