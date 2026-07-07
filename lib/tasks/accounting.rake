# frozen_string_literal: true

namespace :accounting do
  desc 'Verify that every sale.total_cents snapshot matches its recomputed line-item total'
  task verify_totals: :environment do
    mismatches = Sale
                 .includes(articles_sales: :article, sales_subscription_offers: :subscription_offer)
                 .reject { |sale| sale.total_cents == sale.total_price.cents }

    if mismatches.empty?
      puts "OK: all #{Sale.count} sales have a correct total_cents snapshot."
    else
      warn "MISMATCH: #{mismatches.size} sale(s) have a stale total_cents:"
      mismatches.each do |sale|
        warn "  sale ##{sale.id}: stored=#{sale.total_cents} recomputed=#{sale.total_price.cents}"
      end
      abort 'Run a backfill to reconcile.'
    end
  end
end
