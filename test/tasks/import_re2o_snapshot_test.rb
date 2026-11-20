# frozen_string_literal: true

require 'rake'
require 'test_helper'

class ImportRe2oSnapshotTest < ActiveSupport::TestCase
  def setup
    super
    Rake.application.rake_require 'tasks/re2o'
    Rake::Task.define_task(:environment)
  end

  test 'shared emails are dropped and claimed hashes stay wiped' do
    re2o_accounts(:peter).claim!(users(:spiderman))
    account = { 'end_at' => 1.month.from_now.iso8601, 'machines' => [], 'ntlm_hash' => 'AB' }
    snapshot = [account.merge('pseudo' => 'a', 'email' => 'Same@x.fr'),
                account.merge('pseudo' => 'b', 'email' => 'same@x.fr '),
                account.merge('pseudo' => 'spidey', 'email' => 'peter.parker@gmail.com')]

    Tempfile.create(['snapshot', '.json']) do |file|
      file.write(snapshot.to_json)
      file.flush
      Rake::Task['lea5:import_re2o_snapshot'].invoke(file.path)
    end

    assert_nil Re2oAccount.find_by!(pseudo: 'a').email
    assert_nil Re2oAccount.find_by!(pseudo: 'b').email
    assert_nil re2o_accounts(:peter).reload.ntlm_hash
  end
end
