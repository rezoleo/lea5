# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(firstname: "Paul",
                        lastname: "Marcel",
                        email: "paul.marcel@gmail.com",
                        room: "D112")
  end

  test "user is valid" do
    assert @user.valid?
  end

  test "names can't be nil" do
    @user.firstname = nil
    assert_not @user.valid?
    @user.firstname = "Paul"
    @user.lastname = nil
    assert_not @user.valid?
  end

  test "names can't be empty" do
    @user.firstname = "      "
    assert_not @user.valid?
    @user.firstname = "Paul"
    @user.lastname = "         "
    assert_not @user.valid?
  end

  test "email can't be nil" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "email must be of a valid format" do
    valid_emails = %w[users@example.com USER@foo.COM A_US_ER@foo.bar.org
                      first.last@foo.jp alice+bob@baz.cn]
    invalid_emails = ["user@example,com", "user_at_foo.org", "user.name@example",
                      "foo@bar_baz.com", "foo@bar+baz.com", "foo@bar..com", "    "]

    valid_emails.each do |valid_email|
      @user.email = valid_email
      assert @user.valid?, "#{valid_email.inspect} should be valid"
    end

    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not @user.valid?, "#{invalid_email.inspect} should be invalid"
    end
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    @user.save
    duplicate_user.email = "PauL.MarCEl@gMAIl.COm"

    assert_not duplicate_user.valid?
  end
  
  test "room can't be nil" do
    @user.room = nil
    assert_not @user.valid?
  end

  test "room can't be empty" do
    @user.room = "    "
    assert_not @user.valid?
  end

  test "room should be unique" do
    duplicate_user = @user.dup
    @user.save
    duplicate_user.email.downcase!
    assert_not duplicate_user.valid?
  end
end
