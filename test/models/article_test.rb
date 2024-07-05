# frozen_string_literal: true

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  def setup
    @article = articles(:one)
  end

  test 'should be valid' do
    assert_predicate @article, :valid?
  end

  test 'should not be valid without name' do
    @article.name = nil
    assert_not_predicate @article, :valid?
  end

  test 'should not be valid without price' do
    @article.price = nil
    assert_not_predicate @article, :valid?
  end

  test 'price should be integer' do
    @article.price = 10.56
    assert_not_predicate @article, :valid?
  end

  test 'price should be positive' do
    @article.price = -5
    assert_not_predicate @article, :valid?
  end

  test 'article should soft delete' do
    assert_no_difference 'Article.count' do
      @article.soft_delete
    end
  end

  test 'article should be destroyed if no sales' do
    @article.sales.destroy_all
    @article.refunds.destroy_all
    assert_difference 'Article.count', -1 do
      @article.destroy
    end
  end

  test 'article should be destroyable' do
    @article.sales.destroy_all
    @article.refunds.destroy_all
    assert_predicate @article, :can_be_destroyed?
  end
end
