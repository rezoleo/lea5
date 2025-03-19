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
      assert_raises CanCan::AccessDenied do
        get new_article_path
      end
    end

    test 'non-admin user should not create a new article' do
      assert_raises CanCan::AccessDenied do
        post articles_path params: { article: { name: 'New Article', price: 500 } }
      end
    end

    test 'non-admin user should not delete an article' do
      assert_raises CanCan::AccessDenied do
        delete article_path @article
      end
    end
  end
end
