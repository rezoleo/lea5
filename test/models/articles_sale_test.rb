# frozen_string_literal: true

require 'test_helper'

class ArticlesSaleTest < ActiveSupport::TestCase
  def setup
    super
    @sale = sales(:ironman_cable_6_months)
    @article = articles(:cable)
  end

  test 'a deleted article cannot be sold' do
    article_sale = ArticlesSale.new(sale: @sale, article: articles(:deleted_article), quantity: 1)

    assert_not_predicate article_sale, :valid?
    assert_includes article_sale.errors[:article], 'is no longer sold'
  end

  test 'a line without article is invalid without raising' do
    article_sale = ArticlesSale.new(sale: @sale, article: nil, quantity: 1)

    assert_not_predicate article_sale, :valid?
    assert_includes article_sale.errors[:article], 'must exist'
  end

  test 'should not save multiple articles_sale of the same article' do
    ArticlesSale.destroy_all
    ArticlesSale.new(sale_id: @sale.id, article_id: @article.id, quantity: 2).save

    duplicate_article_sale = ArticlesSale.new(sale_id: @sale.id, article_id: @article.id, quantity: 5)
    assert_predicate duplicate_article_sale, :invalid?
    assert duplicate_article_sale.errors.added? :article_id, :taken, value: @article.id

    assert_no_difference 'ArticlesSale.count' do
      ArticlesSale.new(sale_id: @sale.id, article_id: @article.id, quantity: 2).save
    end
  end
end
