# frozen_string_literal: true

require 'minitest/mock'
require 'test_helper'

class MigrationsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test 'anonymous users see the login step' do
    get migration_path

    assert_response :success
    assert_select 'button', 'Log in'
    assert_select 'a[href=?]', 'https://signin.rezoleo.fr', text: 'Create an account'
  end

  test 'a user whose email matches is offered a one-click import' do
    sign_in_as users(:ironman)
    get migration_path

    assert_select 'p', 'We found a re2o account with your email.'

    post claim_migration_path

    assert_redirected_to migration_path
    assert_equal users(:ironman), re2o_accounts(:tony).reload.claimed_by
    follow_redirect!
    assert_select 'h2', 're2o account tstark imported'
  end

  test 'the import animation plays only right after the claim' do
    sign_in_as users(:ironman)
    post claim_migration_path

    get migration_path
    assert_select '[data-controller=migration]'

    get migration_path
    assert_select 'h2', 're2o account tstark imported'
    assert_select '[data-controller=migration]', count: 0
  end

  test 'a user can claim with their re2o password' do
    sign_in_as users(:spiderman)
    get migration_path

    assert_select 'input[name=password]'

    post claim_migration_path, params: { identifier: 'spidey', password: 'webs' }

    assert_equal users(:spiderman), re2o_accounts(:peter).reload.claimed_by
  end

  test 'a wrong password does not claim' do
    sign_in_as users(:spiderman)
    post claim_migration_path, params: { identifier: 'spidey', password: 'nope' }

    assert_redirected_to migration_path
    assert_equal "We couldn't verify this re2o account.", flash[:error]
    assert_not_predicate re2o_accounts(:peter).reload, :claimed?
  end

  test 'send_link emails the re2o address and shows it masked' do
    sign_in_as users(:spiderman)

    assert_enqueued_emails(1) { post send_link_migration_path, params: { identifier: 'spidey' } }
    assert_equal 'We sent a link to p***@g***.com. Open it in this browser, while logged in.', flash[:success]
  end

  test 'send_link reports unknown accounts' do
    sign_in_as users(:spiderman)

    assert_enqueued_emails(0) { post send_link_migration_path, params: { identifier: 'nobody' } }
    assert_equal 'No re2o account with this username.', flash[:error]
  end

  test 'lookup returns the masked email of a re2o account' do
    sign_in_as users(:spiderman)

    get lookup_migration_path(identifier: 'spidey'), as: :json
    assert_equal({ 'masked_email' => 'p***@g***.com' }, response.parsed_body)

    get lookup_migration_path(identifier: 'nobody'), as: :json
    assert_equal({ 'masked_email' => nil }, response.parsed_body)
  end

  test 'the emailed link shows a confirmation, and only the POST claims' do
    token = re2o_accounts(:peter).generate_token_for(:claim)
    sign_in_as users(:spiderman)

    get link_migration_path(token: token)

    assert_select 'h2', 'Import re2o account spidey?'
    assert_not_predicate re2o_accounts(:peter).reload, :claimed?

    post claim_migration_path, params: { token: token }

    assert_predicate re2o_accounts(:peter).reload, :claimed?
  end

  test 'an invalid link says so' do
    get link_migration_path(token: 'garbage')

    assert_select 'h2', 'This link is no longer valid'
  end

  test 'claiming requires to be logged in' do
    post claim_migration_path, params: { identifier: 'spidey', password: 'webs' }

    assert_redirected_to migration_path
    assert_not_predicate re2o_accounts(:peter).reload, :claimed?
  end

  test 'an already migrated user sees the report' do
    sign_in_as users(:pepper)
    get migration_path

    assert_select 'h2', 're2o account ppotts imported'
  end

  test 'an admin can link a re2o account by hand' do
    sign_in_as users(:ironman), ['rezoleo']
    post admin_claim_migration_path, params: { username: users(:spiderman).username, pseudo: 'SPIDEY' }

    assert_redirected_to users(:spiderman)
    assert_equal users(:spiderman), re2o_accounts(:peter).reload.claimed_by
  end

  test 'a non admin cannot link a re2o account by hand' do
    sign_in_as users(:spiderman)

    assert_raises CanCan::AccessDenied do
      post admin_claim_migration_path, params: { username: users(:spiderman).username, pseudo: 'spidey' }
    end
  end
  test 'an unknown account with a password does not claim' do
    sign_in_as users(:spiderman)
    post claim_migration_path, params: { identifier: 'nobody', password: 'webs' }

    assert_equal "We couldn't verify this re2o account.", flash[:error]
  end

  test 'an already migrated user cannot claim another account' do
    sign_in_as users(:pepper)
    post claim_migration_path, params: { identifier: 'spidey', password: 'webs' }

    assert_redirected_to migration_path
    assert_equal 'Your lea5 account has already been migrated from re2o.', flash[:error]
    assert_not_predicate re2o_accounts(:peter).reload, :claimed?
  end

  test 'send_link refuses accounts without email' do
    re2o_accounts(:peter).update!(email: nil)
    sign_in_as users(:spiderman)

    assert_enqueued_emails(0) { post send_link_migration_path, params: { identifier: 'spidey' } }
    assert_equal 'This re2o account has no email. Use your password, or come see us at the helpdesk.', flash[:error]
  end

  test 'too many attempts are rate limited' do
    sign_in_as users(:spiderman)

    MigrationsController.cache_store.stub(:increment, 100) do
      post claim_migration_path, params: { identifier: 'spidey', password: 'webs' }
    end

    assert_redirected_to migration_path
    assert_equal 'Too many attempts, please try again later.', flash[:error]
    assert_not_predicate re2o_accounts(:peter).reload, :claimed?
  end

  test 'an admin linking an unknown pseudo gets an error' do
    sign_in_as users(:ironman), ['rezoleo']
    post admin_claim_migration_path, params: { username: users(:spiderman).username, pseudo: 'nobody' }

    assert_redirected_to users(:spiderman)
    assert_equal 'No unclaimed re2o account with this pseudo.', flash[:error]
  end

  test 'an admin cannot link a second account to a migrated user' do
    sign_in_as users(:ironman), ['rezoleo']
    post admin_claim_migration_path, params: { username: users(:pepper).username, pseudo: 'spidey' }

    assert_redirected_to users(:pepper)
    assert_equal 'Your lea5 account has already been migrated from re2o.', flash[:error]
  end

  test 'the admin link form asks for confirmation' do
    sign_in_as users(:ironman), ['rezoleo']
    get user_path(users(:spiderman))

    assert_select 'form[action=?][data-turbo-confirm]', admin_claim_migration_path
  end
end
