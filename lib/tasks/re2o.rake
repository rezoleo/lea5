# frozen_string_literal: true

namespace :lea5 do
  desc 'Load the re2o snapshot (JSON from lib/re2o/export_snapshot.py). Safe to run again: claims are kept.'
  task :import_re2o_snapshot, [:path] => [:environment] do |_task, args|
    now = Time.current
    rows = JSON.parse(File.read(args.fetch(:path))).map do |account|
      # upsert_all skips model normalization, so normalize like Re2oAccount does
      account.slice('firstname', 'lastname', 'room', 'end_at', 'machines').merge(
        'pseudo' => account['pseudo'].strip.downcase,
        'email' => account['email']&.strip&.downcase.presence,
        'ntlm_hash' => account['ntlm_hash']&.strip&.downcase.presence,
        'created_at' => now,
        'updated_at' => now
      )
    end

    duplicates = rows.filter_map { |row| row['email'] }.tally.select { |_, count| count > 1 }.keys
    rows.each { |row| row['email'] = nil if duplicates.include?(row['email']) }

    if rows.any?
      # Only the snapshot columns are updated: claims and reports are kept
      Re2oAccount.upsert_all(rows, unique_by: :pseudo, update_only: rows.first.keys.excluding('created_at')) # rubocop:disable Rails/SkipsModelValidations
      # A re-import must not bring back the hashes wiped at claim time
      Re2oAccount.where.not(claimed_at: nil).update_all(ntlm_hash: nil) # rubocop:disable Rails/SkipsModelValidations
    end
    puts "Loaded #{rows.size} re2o accounts"
  end
end
