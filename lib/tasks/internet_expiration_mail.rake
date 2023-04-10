# frozen_string_literal: true

namespace :lea5 do
  desc 'send mail to users whose internet will expire soon'
  task internet_expiration_mail: [:environment] do
    User.all.each do |user|
      break if user.subscription_expiration.nil?

      if 7.days.from_now.to_date == user.subscription_expiration.to_date
        puts 'SEDING 7 DAYS'
        UserMailer.with(user:).internet_expiration_7_days.deliver_now
      end

      if 1.day.from_now.to_date == user.subscription_expiration.to_date
        puts 'SEDING 1 DAY'
        UserMailer.with(user:).internet_expiration_1_day.deliver_now
      end
    end
  end
end
