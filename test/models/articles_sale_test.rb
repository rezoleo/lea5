# frozen_string_literal: true

require 'test_helper'

class ArticlesSaleTest < ActiveSupport::TestCase
  def setup
    super
    @sale = sales(:ironman_cable_6_months)
    @article = articles(:cable)
  end

  test 'should throw an error if multiple articles_sale of the same article' do
    ArticlesSale.destroy_all
    ArticlesSale.new(sale_id: @sale.id, article_id: @article.id, quantity: 2).save

    duplicate_article_sale = ArticlesSale.new(sale_id: @sale.id, article_id: @article.id, quantity: 5)
    assert_predicate duplicate_article_sale, :invalid?
    assert duplicate_article_sale.errors.added? :article_id, :taken, value: @article.id
  end
end
