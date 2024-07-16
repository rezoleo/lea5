# frozen_string_literal: true

require 'test_helper'

module Admin
  class ArticlesControllerTest < ActionDispatch::IntegrationTest
    def setup
      @articles = articles(:one)
      @user = users(:ironman)
      sign_in_as @user, ['rezoleo']
    end

    test 'should get new' do
      get new_article_path
      assert_template 'admin/articles/new'
    end

    test 'should create article' do
      assert_difference 'Article.unscoped.count', 1 do
        post articles_path, params: { article: { name: 'test_name', price: 1456 } }
      end
      assert_redirected_to admin_path
    end

    test 'should re-render if missing article information' do
      assert_no_difference 'Article.unscoped.count' do
        post articles_path, params: { article: { name: nil } }
      end

      assert_template 'admin/articles/new'
    end

    test 'should soft_delete article' do
      assert_no_difference 'Article.unscoped.count' do
        delete article_path(@articles)
      end
      assert_redirected_to admin_path
    end
  end
end
