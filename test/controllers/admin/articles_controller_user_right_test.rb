# frozen_string_literal: true

require 'test_helper'

module Admin
  class ArticlesControllerUserRightTest < ActionDispatch::IntegrationTest
    def setup
      super
      @user = users(:pepper)
      sign_in_as @user

      @article = articles(:cable)
    end

    test 'non-admin user should not see article creation page' do
      get new_article_path
      assert_response :forbidden
    end

    test 'non-admin user should not create a new article' do
      post articles_path params: { article: { name: 'New Article', price: 5.00 } }
      assert_response :forbidden
    end

    test 'non-admin user should not delete an article' do
      delete article_path @article
      assert_response :forbidden
    end
  end
end
