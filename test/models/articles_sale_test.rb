# frozen_string_literal: true

require 'test_helper'

class ArticlesSaleTest < ActiveSupport::TestCase
  def setup
    @sale = sales(:one)
    @article = articles(:one)
  end

  test 'should throw an error if multiple articles_sale of the same article' do
    ArticlesSale.destroy_all
    ArticlesSale.new(sale_id: @sale.id, article_id: @article.id, quantity: 2).save
    assert_throws :abort do
      ArticlesSale.new(sale_id: @sale.id, article_id: @article.id, quantity: 2).send(:consolidate_duplication)
    end
  end
end
