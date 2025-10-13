# frozen_string_literal: true

require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  def setup
    super
    @user = users(:ironman)
    @api_key = api_keys(:FakeRadius)
  end

  test 'api key is valid' do
    assert_predicate @api_key, :valid?
  end

  test "name can't be nil" do
    @api_key.name = nil
    assert_not_predicate @api_key, :valid?
  end

  test "names can't be empty" do
    @api_key.name = '      '
    assert_not_predicate @api_key, :valid?
  end

  test 'generate api key digest before create' do
    api_key = ApiKey.new(name: 'api_key')
    assert_nil api_key.api_key_digest
    api_key.save
    assert_not_nil api_key.api_key_digest
  end
end
