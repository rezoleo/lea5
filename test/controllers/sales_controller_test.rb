# frozen_string_literal: true

require 'test_helper'

class SalesControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    @user = users(:pepper)
    @admin = users(:ironman)
    @payment_method = payment_methods(:credit_card)
    @article = articles(:cable)
    @sale_params = {
      payment_method_id: @payment_method.id,
      duration: 30,
      articles_sales_attributes: [
        { article_id: @article.id, quantity: 2 }
      ]
    }
    sign_in_as @admin, ['rezoleo']
  end

  test 'should get new sale form' do
    get new_user_sale_path(user_id: @user.id)
    assert_response :success
    assert_template 'sales/new'
    assert_select 'form'
  end

  test 'should create sale and redirect if sale is valid' do
    assert_difference 'Sale.count', 1 do
      post user_sales_path(user_id: @user.id, format: :html), params: { sale: @sale_params }
    end
    assert_redirected_to @user
    assert_equal 'Sale was successfully created.', flash[:success]
  end

  test 'should not create sale and redirect if duration is negative' do
    @sale_params[:duration] = -5
    assert_no_difference 'Sale.count' do
      post user_sales_path(user_id: @user.id, format: :html), params: { sale: @sale_params }
    end
    assert_response :unprocessable_entity
    assert_template 'sales/new'
  end

  test 'should not create sale and redirect if sale is invalid' do
    @sale_params[:payment_method_id] = PaymentMethod.last.id + 1
    assert_no_difference 'Sale.count' do
      post user_sales_path(user_id: @user.id, format: :html), params: { sale: @sale_params }
    end
    assert_response :unprocessable_entity
    assert_template 'sales/new'
  end

  test 'should not create sale and redirect if sale is empty' do
    @sale_params[:duration] = 0
    @sale_params.delete(:articles_sales_attributes)
    assert_no_difference 'Sale.count' do
      post user_sales_path(user_id: @user.id, format: :html), params: { sale: @sale_params }
    end
    assert_response :unprocessable_entity
    assert_template 'sales/new'
  end
end
