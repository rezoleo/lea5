# frozen_string_literal: true

require 'test_helper'

class SsoMetadataServiceTest < ActiveSupport::TestCase
  def setup
    super

    @user = users(:ironman)
    Rails.application.credentials.sso_lea5_pat = 'test-pat-token'
  end

  test 'sync_room skips user without oidc_id' do
    @user.oidc_id = nil
    assert_nothing_raised do
      SsoMetadataService.new.sync_room(@user)
    end
  end

  test 'sync_room does not call SSO in non-production' do
    assert_not_equal 'production', Rails.env

    SsoMetadataService.new.sync_room(@user)
  end

  test 'sync_room pushes metadata in production' do
    room_number = @user.room.number
    stub = WebMock.stub_request(:post, "https://sso.rezoleo.fr/v2/users/#{@user.oidc_id}/metadata")
                  .with(
                    headers: { 'Authorization' => 'Bearer test-pat-token', 'Content-Type' => 'application/json' },
                    body: {
                      metadata: [{ key: 'room', value: Base64.strict_encode64(room_number) }]
                    }.to_json
                  )
                  .to_return(status: 200, body: '{"setDate":"2026-01-01T00:00:00Z"}')

    ProductionSsoService.new.sync_room(@user)
    assert_requested(stub)
  end

  test 'sync_room sends DELETE when user has no room' do
    user = users(:spiderman) # User without a room

    stub = WebMock.stub_request(:delete, "https://sso.rezoleo.fr/v2/users/#{user.oidc_id}/metadata")
                  .with(query: { 'keys' => 'room' })
                  .to_return(status: 200, body: '{"deletionDate":"2026-01-01T00:00:00Z"}')

    ProductionSsoService.new.sync_room(user)
    assert_requested(stub)
  end

  test 'sync_room does not raise on POST HTTP failure' do
    WebMock.stub_request(:post, "https://sso.rezoleo.fr/v2/users/#{@user.oidc_id}/metadata")
           .to_return(status: 500, body: 'Internal Server Error')

    assert_nothing_raised do
      ProductionSsoService.new.sync_room(@user)
    end
  end

  test 'sync_room raises on POST network exception' do
    WebMock.stub_request(:post, "https://sso.rezoleo.fr/v2/users/#{@user.oidc_id}/metadata")
           .to_raise(Errno::ECONNREFUSED)

    assert_raises(Errno::ECONNREFUSED) do
      ProductionSsoService.new.sync_room(@user)
    end
  end

  test 'sync_room does not raise on DELETE HTTP failure' do
    user = users(:spiderman) # User without a room

    WebMock.stub_request(:delete, "https://sso.rezoleo.fr/v2/users/#{user.oidc_id}/metadata")
           .with(query: { 'keys' => 'room' })
           .to_return(status: 500, body: 'Internal Server Error')

    assert_nothing_raised do
      ProductionSsoService.new.sync_room(user)
    end
  end

  test 'sync_room raises on DELETE network exception' do
    user = users(:spiderman) # User without a room

    WebMock.stub_request(:delete, "https://sso.rezoleo.fr/v2/users/#{user.oidc_id}/metadata")
           .with(query: { 'keys' => 'room' })
           .to_raise(Errno::ECONNREFUSED)

    assert_raises(Errno::ECONNREFUSED) do
      ProductionSsoService.new.sync_room(user)
    end
  end

  test 'sync_room raises on timeout' do
    user = users(:spiderman) # User without a room

    WebMock.stub_request(:delete, "https://sso.rezoleo.fr/v2/users/#{user.oidc_id}/metadata")
           .with(query: { 'keys' => 'room' })
           .to_raise(Net::ReadTimeout.new)

    assert_raises(Net::ReadTimeout) do
      ProductionSsoService.new.sync_room(user)
    end
  end
end

# Test subclass that overrides production? to always return true
class ProductionSsoService < SsoMetadataService
  private

  def production?
    true
  end
end
