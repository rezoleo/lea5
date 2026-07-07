# frozen_string_literal: true

require 'test_helper'

class RefundsControllerUserRightTest < ActionDispatch::IntegrationTest
  def setup
    super
    @user = users(:pepper)
    @sale = sales(:ironman_deleted_article)
    sign_in_as @user
  end

  test 'non-admin user should not see refund creation page' do
    assert_raises CanCan::AccessDenied do
      get new_sale_refund_path(@sale)
    end
  end

  test 'non-admin user should not create a refund' do
    assert_raises CanCan::AccessDenied do
      post sale_refunds_path(@sale), params: { refund: {
        refund_method_id: payment_methods(:cash).id,
        article_ids: [articles(:deleted_article).id]
      } }
    end
  end
end
