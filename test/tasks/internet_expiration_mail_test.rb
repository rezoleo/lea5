# frozen_string_literal: true

require 'rake'
require 'test_helper'

class InternetExpirationMailTest < ActionDispatch::IntegrationTest
  # https://blog.10pines.com/2019/01/14/testing-rake-tasks/
  # https://thoughtbot.com/blog/test-rake-tasks-like-a-boss
  def setup
    Rake.application.rake_require 'tasks/internet_expiration_mail'
    Rake::Task.define_task(:environment)
    @user = users(:ironman)
  end

  test 'should send an email when subscription expires in 7 days' do
    @user.subscriptions.destroy_all
    @user.subscriptions.new(start_at: Time.current, end_at: 7.days.from_now)
    @user.save
    assert_emails 1 do
      Rake::Task['lea5:internet_expiration_mail'].invoke
    end
    assert_equal 'Your internet will expire in 7 days', UserMailer.deliveries.first.subject
  end

  test 'should send an email when subscription expires tomorrow' do
    @user.subscriptions.destroy_all
    @user.subscriptions.new(start_at: Time.current, end_at: 1.day.from_now)
    @user.save
    assert_emails 1 do
      Rake::Task['lea5:internet_expiration_mail'].invoke
    end

    assert_equal 'Your internet will expire tomorrow', UserMailer.deliveries.first.subject
  end

  test 'should not send an email when subscription expires between 7 days and 1 day' do
    @user.subscriptions.destroy_all
    @user.subscriptions.new(start_at: Time.current, end_at: 6.days.from_now)
    @user.save
    assert_emails 0 do
      Rake::Task['lea5:internet_expiration_mail'].invoke
    end
  end
end
