# frozen_string_literal: true

require 'test_helper'

class Re2oMigrationMailerTest < ActionMailer::TestCase
  test 'claim_link sends the link to the re2o email' do
    account = re2o_accounts(:peter)
    mail = Re2oMigrationMailer.with(account: account, token: 'tok').claim_link

    assert_equal ['peter.parker@gmail.com'], mail.to
    assert_includes mail.text_part.body.to_s, 'token=tok'
  end
end
