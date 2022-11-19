# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(firstname: 'Paul',
                     lastname: 'Marcel',
                     email: 'paul.marcel@gmail.com',
                     room: 'D112')
    @auth_hash = { provider: 'keycloak',
                   uid: '11111111-1111-1111-1111-111111111111',
                   info: { first_name: 'John',
                           last_name: 'Doe',
                           email: 'john@doe.com' },
                   extra: { raw_info: { room: 'F123' } } }
  end

  test 'user is valid' do
    assert_predicate @user, :valid?
  end

  test "names can't be nil" do
    @user.firstname = nil
    assert_not_predicate @user, :valid?
    @user.firstname = 'Paul'
    @user.lastname = nil
    assert_not_predicate @user, :valid?
  end

  test "names can't be empty" do
    @user.firstname = '      '
    assert_not_predicate @user, :valid?
    @user.firstname = 'Paul'
    @user.lastname = '         '
    assert_not_predicate @user, :valid?
  end

  test "email can't be nil" do
    @user.email = nil
    assert_not_predicate @user, :valid?
  end

  test 'email must be of a valid format' do
    valid_emails = %w[users@example.com USER@foo.COM A_US_ER@foo.bar.org
                      first.last@foo.jp alice+bob@baz.cn]
    invalid_emails = ['user@example,com', 'user_at_foo.org', 'user.name@example',
                      'foo@bar_baz.com', 'foo@bar+baz.com', 'foo@bar..com', '    ']

    valid_emails.each do |valid_email|
      @user.email = valid_email
      assert_predicate @user, :valid?, "#{valid_email.inspect} should be valid"
    end

    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not_predicate @user, :valid?, "#{invalid_email.inspect} should be invalid"
    end
  end

  test 'email should be unique' do
    duplicate_user = @user.dup
    @user.save
    assert_not_predicate duplicate_user, :valid?
  end

  test 'email should be downcase on save' do
    @user.email = 'PauL.MarCEl@gMAIl.COm'
    @user.save
    assert_equal 'paul.marcel@gmail.com', @user.email
  end

  test "room can't be nil" do
    @user.room = nil
    assert_not_predicate @user, :valid?
  end

  test "room can't be empty" do
    @user.room = '    '
    assert_not_predicate @user, :valid?
  end

  test 'room should be unique' do
    duplicate_user = @user.dup
    @user.save
    duplicate_user.room.downcase!
    assert_not_predicate duplicate_user, :valid?
  end

  test 'room should be formatted on save' do
    @user.room = 'a108B'
    @user.save
    assert_equal 'A108b', @user.room
  end

  test 'room must be of a valid format' do
    valid_rooms = %w[A205 B134a C001b F313 D111b E231a DF1 DF2 DF3 DF4]
    invalid_rooms = %w[A2005 C404 D111c B1 E22 G207]

    valid_rooms.each do |valid_room|
      @user.room = valid_room
      assert_predicate @user, :valid?, "#{valid_room} should be valid"
    end

    invalid_rooms.each do |invalid_room|
      @user.room = invalid_room
      assert_not_predicate @user, :valid?, "#{invalid_room} should be invalid"
    end
  end

  test 'machines should be sorted by creation date' do
    @user.save
    machine1 = @user.machines.create(name: 'Machine-1', mac: '11:11:11:11:11:11')
    @user.machines.create(name: 'Machine-2', mac: '22:22:22:22:22:22')
    machine1.update(mac: '33:33:33:33:33:33')
    assert_equal @user.machines.sort_by(&:created_at), @user.machines
  end

  test 'should create new user from auth hash' do
    assert_difference 'User.count', 1 do
      created_user = User.upsert_from_auth_hash(@auth_hash)
      assert_equal 'John', created_user.firstname
      assert_equal 'Doe', created_user.lastname
      assert_equal 'john@doe.com', created_user.email
      assert_equal 'F123', created_user.room
      assert_equal '11111111-1111-1111-1111-111111111111', created_user.keycloak_id
    end
  end

  test 'should return existing user from auth hash' do
    @user.update(keycloak_id: '11111111-1111-1111-1111-111111111111')
    @user.save

    assert_difference 'User.count', 0 do
      updated_user = User.upsert_from_auth_hash(@auth_hash)
      assert_equal @user.id, updated_user.id
    end
  end

  test 'should update existing user from auth hash' do
    @user.update(keycloak_id: '11111111-1111-1111-1111-111111111111')
    @user.save

    User.upsert_from_auth_hash(@auth_hash)
    @user.reload

    assert_equal 'John', @user.firstname
    assert_equal 'Doe', @user.lastname
    assert_equal 'john@doe.com', @user.email
    assert_equal 'F123', @user.room
    assert_equal '11111111-1111-1111-1111-111111111111', @user.keycloak_id
  end
end
