require "test_helper"

class Admin::SubscriptionOffersControllerTest < ActionDispatch::IntegrationTest
  test "should get admin/payment_methods" do
    get admin_subscription_offers_admin/payment_methods_url
    assert_response :success
  end
end
