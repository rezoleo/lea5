# frozen_string_literal: true

require 'test_helper'

class Re2oAccountTest < ActiveSupport::TestCase
  def setup
    super
    @tony = re2o_accounts(:tony)
    @peter = re2o_accounts(:peter)
  end

  test 'claim imports the access, keeps the existing room and only adds new machines' do
    user = users(:ironman)
    expected_start = [user.internet_expiration, Time.current].compact.max

    report = nil
    assert_difference 'user.machines.count', 1 do
      report = @tony.claim!(user)
    end

    assert_equal user, @tony.reload.claimed_by
    access = user.free_accesses.find_by!(reason: Re2oAccount::MIGRATION_REASON)
    assert_in_delta expected_start, access.start_at, 1
    assert_in_delta access.start_at + (@tony.end_at - @tony.claimed_at), access.end_at, 2
    assert_equal({ 'status' => 'kept', 'number' => 'A109A' }, report['room'])
    assert_equal ['imported', 'skipped', 'skipped'], report['machines'].pluck('status')
    assert_equal 'Already on your account', report['machines'][1]['reason']
    assert_equal 'Registered on another account', report['machines'][2]['reason']
    assert_equal users(:pepper), Machine.find_by(mac: 'DE:1A:B3:17:95:B8').user
    assert_predicate @tony, :claim_skipped_anything?
  end

  test 'claim wipes the re2o NTLM hash' do
    @peter.claim!(users(:spiderman))

    assert_nil @peter.reload.ntlm_hash
  end

  test 'claim never changes the lea5 identity of the user' do
    user = users(:spiderman)
    identity = user.attributes.slice('firstname', 'lastname', 'email', 'username', 'oidc_id', 'wifi_password')

    @peter.claim!(user)

    assert_equal identity, user.reload.attributes.slice(*identity.keys)
  end

  test 'masked_email hides most of the address' do
    assert_equal 'p***@g***.com', @peter.masked_email
    assert_equal 'p***@l***', Re2oAccount.new(email: 'peter@localhost').masked_email
    assert_nil Re2oAccount.new.masked_email
  end

  test 'claim assigns the re2o room when the user has none' do
    report = @peter.claim!(users(:spiderman))

    assert_equal({ 'status' => 'imported', 'number' => 'B231' }, report['room'])
    assert_equal users(:spiderman), rooms(:room_b231).reload.user
  end

  test 'claim skips a room occupied by someone else' do
    @peter.update!(room: 'a201')

    report = @peter.claim!(users(:spiderman))

    assert_equal 'skipped', report['room']['status']
    assert_equal users(:pepper), rooms(:room_a201).reload.user
  end

  test 'claim adds the remaining re2o time after the current access' do
    user = User.create!(firstname: 'Miles', lastname: 'Morales', email: 'miles@univ.edu', username: 'miles')
    freeze_time do
      current_end = 10.days.from_now
      user.free_accesses.create!(reason: 'Gift', start_at: Time.current, end_at: current_end)
      @peter.update!(end_at: 60.days.from_now)

      @peter.claim!(user)

      access = user.free_accesses.find_by!(reason: Re2oAccount::MIGRATION_REASON)
      assert_in_delta current_end, access.start_at, 1
      assert_in_delta current_end + 60.days, access.end_at, 1
    end
  end

  test 'claim skips the access when re2o time has ended' do
    @peter.update!(end_at: 1.day.ago)

    report = @peter.claim!(users(:spiderman))

    assert_equal 'skipped', report['access']['status']
    assert_not users(:spiderman).free_accesses.exists?(reason: Re2oAccount::MIGRATION_REASON)
  end

  test 'an invalid machine is skipped without cancelling the claim' do
    @peter.update!(machines: [{ 'mac' => 'not-a-mac', 'name' => 'broken' },
                              { 'mac' => 'aa:bb:cc:dd:ee:03', 'name' => 'ok' }])

    report = @peter.claim!(users(:spiderman))

    assert_equal ['skipped', 'imported'], report['machines'].pluck('status')
    assert_predicate @peter.reload, :claimed?
  end

  test 'an account can only be claimed once' do
    @peter.claim!(users(:spiderman))

    assert_raises(Re2oAccount::ClaimError) { @peter.claim!(users(:ironman)) }
  end

  test 'a user can only claim one account' do
    assert_raises(Re2oAccount::ClaimError) { @peter.claim!(users(:pepper)) }
    assert_not_predicate @peter.reload, :claimed?
  end

  test 'password_matches? checks the re2o NTLM hash' do
    assert @peter.password_matches?('webs')
    assert_not @peter.password_matches?('wrong')
    assert_not @peter.password_matches?('')
  end

  test 'lookup finds unclaimed accounts by pseudo or email, ignoring case' do
    assert_equal @peter, Re2oAccount.lookup(' SPIDEY ')
    assert_equal @peter, Re2oAccount.lookup('Peter.Parker@gmail.com')
    assert_nil Re2oAccount.lookup('ppotts')
    assert_nil Re2oAccount.lookup('')
  end

  test 'claim token is invalidated by the claim' do
    token = @peter.generate_token_for(:claim)
    assert_equal @peter, Re2oAccount.find_by_token_for(:claim, token)

    @peter.claim!(users(:spiderman))

    assert_nil Re2oAccount.find_by_token_for(:claim, token)
  end
end
