# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test 'internet expiration 7 days' do
    # Create the email and store it for further assertions
    user = users(:ironman)
    email = UserMailer.with(user:).internet_expiration_7_days

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['no-reply@rezoleo.fr'], email.from
    assert_equal [user.email], email.to
    assert_equal 'Your internet will expire in 7 days', email.subject
    assert_equal read_fixture('internet_expiration_7_days.text').join.strip, email.text_part.body.to_s.strip
    assert_equal read_fixture('internet_expiration_7_days.html').join.strip, email.html_part.body.to_s.strip
  end

  test 'internet expiration 1 day' do
    # Create the email and store it for further assertions
    user = users(:ironman)
    email = UserMailer.with(user:).internet_expiration_1_day

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ['no-reply@rezoleo.fr'], email.from
    assert_equal [user.email], email.to
    assert_equal 'Your internet will expire tomorrow', email.subject
    assert_equal read_fixture('internet_expiration_1_day.text').join.strip, email.text_part.body.to_s.strip
    assert_equal read_fixture('internet_expiration_1_day.html').join.strip, email.html_part.body.to_s.strip
  end
end
