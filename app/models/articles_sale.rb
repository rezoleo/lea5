# frozen_string_literal: true

class ArticlesSale < ApplicationRecord
  belongs_to :sale
  belongs_to :article

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  before_create :sale_persisted
  before_create :consolidate_duplication

  private

  def sale_persisted
    throw :abort if sale.persisted?
  end

  def consolidate_duplication
    duplicate = ArticlesSale.where(article_id: article_id, sale_id: sale_id).where.not(id: id).first
    return unless duplicate

    errors.add(:base, 'Please merge the quantities of the same articles !')
    throw :abort
  end
end
