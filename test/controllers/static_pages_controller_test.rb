# frozen_string_literal: true

require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test 'root render home page' do
    get root_path
    assert_template 'static_pages/home'
  end
end
