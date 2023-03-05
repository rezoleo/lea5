# frozen_string_literal: true

# ApplicationHelper module
module ApplicationHelper
  def time_with_relative_tag(date_or_time)
    time_ago_in_words = if date_or_time > Time.current
                          "in #{time_ago_in_words(date_or_time)}"
                        else
                          "#{time_ago_in_words(date_or_time)} ago"
                        end
    time_tag date_or_time, date_or_time.strftime('%b %d, %Y'), title: time_ago_in_words
  end
end
