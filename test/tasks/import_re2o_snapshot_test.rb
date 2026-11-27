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

    import(snapshot)

    assert_nil Re2oAccount.find_by!(pseudo: 'a').email
    assert_nil Re2oAccount.find_by!(pseudo: 'b').email
    assert_nil re2o_accounts(:peter).reload.ntlm_hash
  end

  test 'missing emails and hashes are kept nil, and an empty snapshot loads nothing' do
    snapshot = [{ 'pseudo' => 'nomail', 'end_at' => 1.month.from_now.iso8601, 'machines' => [] }]
    import(snapshot)
    import([])

    account = Re2oAccount.find_by!(pseudo: 'nomail')
    assert_nil account.email
    assert_nil account.ntlm_hash
  end

  private

  def import(snapshot)
    Tempfile.create(['snapshot', '.json']) do |file|
      file.write(snapshot.to_json)
      file.flush
      Rake::Task['lea5:import_re2o_snapshot'].reenable
      Rake::Task['lea5:import_re2o_snapshot'].invoke(file.path)
    end
  end
end
