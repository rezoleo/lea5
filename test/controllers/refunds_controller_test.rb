# frozen_string_literal: true

require 'test_helper'

class RefundsControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    @admin = users(:ironman)
    @sale = sales(:ironman_deleted_article)
    @article = articles(:deleted_article)
    @refund_method = payment_methods(:cash)
    sign_in_as @admin, ['rezoleo']
  end

  test 'should get new refund form' do
    get new_sale_refund_path(@sale)
    assert_response :success
    assert_template 'refunds/new'
    assert_select 'form'
  end

  test 'should create a refund and redirect to the client' do
    assert_difference 'Refund.count', 1 do
      post sale_refunds_path(@sale), params: { refund: {
        refund_method_id: @refund_method.id,
        article_ids: [@article.id]
      } }
    end
    assert_redirected_to @sale.client
    assert_equal 'Refund created!', flash[:success]
  end

  test 'should not create an empty refund' do
    assert_no_difference 'Refund.count' do
      post sale_refunds_path(@sale), params: { refund: { refund_method_id: @refund_method.id } }
    end
    assert_response :unprocessable_entity
    assert_template 'refunds/new'
  end
end
