# frozen_string_literal: true

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  def setup
    super
    @article = articles(:cable)
  end

  test 'should be valid' do
    assert_predicate @article, :valid?
  end

  test 'should not be valid without name' do
    @article.name = nil
    assert_not_predicate @article, :valid?
  end

  test 'should not be valid without price' do
    @article.price_cents = nil
    assert_not_predicate @article, :valid?
  end

  test 'price should be strictly positive' do
    @article.price_cents = -5
    assert_not_predicate @article, :valid?

    @article.price_cents = 0
    assert_not_predicate @article, :valid?
  end

  test 'article should soft delete' do
    @article.deleted_at = nil
    assert_no_difference 'Article.unscoped.count' do
      @article.soft_delete
    end
    assert_not_nil @article.deleted_at
  end

  test 'soft_delete should not change deleted_at date' do
    @article.deleted_at = 3.days.ago
    before_test = @article.deleted_at
    @article.soft_delete
    assert_equal @article.deleted_at, before_test
  end

  test 'article should be destroyed if no sales' do
    @article.sales.destroy_all
    @article.refunds.destroy_all
    assert_difference 'Article.unscoped.count', -1 do
      assert_predicate @article, :destroy
    end
  end

  test 'article should not destroy if dependant' do
    assert_no_difference 'Article.unscoped.count' do
      assert_not_predicate @article, :destroy
    end

    assert_predicate @article, :persisted?
    assert_includes @article.errors[:base], 'Cannot delete record because dependent articles sales exist'
  end

  test 'only available articles should be sellable' do
    assert_equal 2, Article.sellable.count
  end
end
