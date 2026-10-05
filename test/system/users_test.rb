# frozen_string_literal: true

require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  def setup
    super
    @user = users(:ironman)
    sign_in_as @user
  end

  test 'visiting profile' do
    visit user_path @user

    assert_selector 'h1', text: 'My Profile'

    assert_text @user.firstname
    assert_text @user.lastname
    assert_text @user.email
    assert_text @user.room.number

    @user.machines.each do |machine|
      assert_text machine.name
      assert_text(/#{machine.mac}/i)
      assert_text machine.ip.ip
    end
  end

  test 'moving a user to an occupied room' do
    click_on 'Logout'
    sign_in_as @user, ['rezoleo']
    pepper = users(:pepper)
    target_room = pepper.room.number

    visit user_path @user
    click_on 'Move this user'

    assert_selector 'h1', text: "Move #{@user.firstname} #{@user.lastname}"
    assert_no_field 'Firstname'

    select "#{target_room} (#{pepper.display_name})", from: 'Room'
    click_on 'Move'
    assert_text "is occupied by #{pepper.display_name}"

    check "Unassign the current occupant of #{target_room}"
    click_on 'Move'

    assert_text 'User moved!'
    assert_equal target_room, @user.reload.room.number
    assert_nil pepper.reload.room
  end

  test 'adding a new machine' do
    mac = '11:11:11:11:11:11'

    visit user_path @user
    assert_no_text(/#{mac}/i)

    click_on 'Add a new machine'

    assert_selector 'h1', text: 'Add a new machine'

    fill_in 'Name', with: 'New machine'
    fill_in 'Mac', with: mac
    click_on 'Create'

    assert_selector 'h1', text: 'My Profile'

    assert_text(/#{mac}/i)
  end

  test 'editing a machine' do
    new_name = 'New Name'
    visit user_path @user
    assert_no_text new_name

    click_on 'Edit this machine'

    assert_selector 'h1', text: 'Edit the machine'

    fill_in 'Name', with: new_name
    click_on 'Edit'

    assert_selector 'h1', text: 'My Profile'

    assert_text new_name
  end

  test 'deleting a machine' do
    machine = @user.machines.first

    visit user_path @user
    assert_text(/#{machine.mac}/i)

    accept_confirm do
      click_on 'Delete this machine', match: :first
    end

    assert_no_text(/#{machine.mac}/i)
  end

  test 'signing in should redirect to user profile' do
    sign_out
    sign_in_as @user

    assert_selector 'h1', text: 'My Profile'
    assert_text @user.email
  end

  test 'signing out should redirect to root page' do
    sign_out
    sign_in_as @user

    sign_out

    assert_selector 'h1', count: 0
  end
end
