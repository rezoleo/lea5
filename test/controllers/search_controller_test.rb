# frozen_string_literal: true

require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    @admin = users(:ironman)
    @machine = machines(:jarvis)
    @ip = ips(:ip1)

    sign_in_as @admin, ['rezoleo']
  end

  test 'should work with empty query' do
    get search_path
    assert_response :success
  end

  test 'should return nothing for unknown user' do
    non_matching_users = ['Nymous', 'Nymou', 'Laurent', 'Gadac']

    non_matching_users.each do |user|
      get search_path, params: { q: user }
      assert_response :success
      assert_no_match 'Results among users:', @response.body, "should return nothing for #{user} (user not in DB)"
    end
  end

  test 'should return coherent results for known user' do
    searches_and_matches = {
      Tony: 1,
      tony: 1,
      to: 1,
      Pepper: 1,
      pe: 2
    }

    searches_and_matches.each do |(user, number)|
      assert_msg = "should return #{number} result(s) for #{user}"
      get search_path, params: { q: user }
      assert_response :success
      assert_match 'Results among users:', @response.body, assert_msg
      assert_dom '.user', { count: number, text: /.*#{Regexp.escape(user)}.*/mi }
    end
  end

  test 'should return nothing for unknown mac' do
    non_matching_macs = ['DE:1A:B3:17:95:B9', 'DC:1A:B3:17:95:B9']

    non_matching_macs.each do |mac|
      get search_path, params: { q: mac }
      assert_response :success
      assert_no_match 'Results among machines:', @response.body, "should return nothing for #{mac} (mac not in DB)"
    end
  end

  test 'should return coherent results for known mac' do
    searches_and_matches = {
      C9: 1,
      B8: 1,
      c9: 1,
      b8: 1,
      'DE:1A:B3:17:95': 3,
      jarvis: 1
    }

    searches_and_matches.each do |(mac, number)|
      assert_msg = "should return #{number} result(s) for #{mac}"
      get search_path, params: { q: mac }
      assert_response :success
      assert_match 'Results among machines:', @response.body, assert_msg
      assert_dom '.machine-search', { count: number, text: /.*#{Regexp.escape(mac)}.*/mi }
    end
  end

  test 'should return nothing for non matching ips or unknown ip' do
    invalid_ips = ['300.255', 'not.an.ip', '172.130.0.20']

    invalid_ips.each do |query|
      get search_path, params: { q: query }
      assert_response :success
      assert_no_match 'Results among machines:', @response.body, "should not return result for #{query}"
    end
  end

  test 'should return a unique machine for known ip' do
    valid_ips = ['172.130.0.1', '172.130.0.0']

    valid_ips.each do |query|
      get search_path, params: { q: query }
      assert_response :success
      assert_match 'Results among machines:', @response.body, "should return something for #{query}"
      assert_dom '.machine-search', { count: 1, text: /.*#{Regexp.escape(query)}.*/ }
    end
  end

  test 'should paginate user results' do
    limit = Pagy::OPTIONS[:limit]
    # Two full pages plus a partial one, whatever the configured limit is.
    create_matching_users((limit * 2) + 1)

    get search_path, params: { q: 'Paginated' }
    assert_dom '.user', count: limit

    get search_path, params: { q: 'Paginated', users_page: 3 }
    assert_dom '.user', count: 1
  end

  test 'should paginate each result list independently' do
    limit = Pagy::OPTIONS[:limit]
    create_matching_users((limit * 2) + 1)

    # Paging the users list must not affect the machines list, and vice versa.
    get search_path, params: { q: 'Paginated', users_page: 3 }
    assert_response :success
    assert_dom '.user', count: 1

    get search_path, params: { q: 'Paginated', machines_page: 2 }
    assert_response :success
    assert_dom '.user', count: limit
  end

  test 'should keep the query when linking to another page' do
    create_matching_users((Pagy::OPTIONS[:limit] * 2) + 1)

    get search_path, params: { q: 'Paginated' }
    assert_dom '.pagination a[href*=?]', 'q=Paginated'
    assert_dom '.pagination a[href*=?]', 'users_page='
  end

  test 'should not paginate search results that fit on a single page' do
    get search_path, params: { q: 'Tony' }
    assert_dom '.pagination', count: 0
  end

  private

  def create_matching_users(count)
    count.times do |i|
      User.create!(
        firstname: 'Search',
        lastname: format('Paginated%03d', i),
        email: "search#{i}@paginated.com",
        username: "search-#{i}",
        wifi_password: 'password'
      )
    end
  end
end
