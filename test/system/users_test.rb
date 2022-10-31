# frozen_string_literal: true

require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  def setup
    @user = users(:ironman)
  end

  test 'visiting profile' do
    visit user_path @user

    assert_selector 'h1', text: 'My Profile'

    assert_text @user.firstname
    assert_text @user.lastname
    assert_text @user.email
    assert_text @user.room

    @user.machines.each do |machine|
      assert_text machine.name
      assert_text(/#{machine.mac}/i)
      assert_text machine.ip.ip
    end
  end

  test 'editing the profile' do
    new_firstname = 'Elon'
    new_lastname = 'Musk'

    visit user_path @user
    assert_no_text new_firstname
    assert_no_text new_lastname

    click_on 'Edit your profile'

    assert_selector 'h1', text: 'Users#Edit'

    fill_in 'Firstname', with: new_firstname
    fill_in 'Lastname', with: new_lastname
    click_on 'Edit'

    assert_selector 'h1', text: 'My Profile'
    assert_text new_firstname
    assert_text new_lastname
  end

  test 'adding a new machine' do
    mac = '11:11:11:11:11:11'

    visit user_path @user
    assert_no_text(/#{mac}/i)

    click_on 'Add a new machine'

    assert_selector 'h1', text: 'Machines#new'

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

    assert_selector 'h1', text: 'Machines#Edit'

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
end
