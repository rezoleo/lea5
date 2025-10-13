# frozen_string_literal: true

module ApplicationHelper
  def time_with_relative_tag(date_or_time)
    time_ago_in_words = if date_or_time > Time.current
                          "in #{time_ago_in_words(date_or_time)}"
                        else
                          "#{time_ago_in_words(date_or_time)} ago"
                        end
    time_tag date_or_time, date_or_time.strftime('%b %d, %Y'), title: time_ago_in_words
  end

  def svg_icon_tag(name, **)
    icons_path = asset_path 'icons.svg'
    tag.svg(**) do
      tag.use(href: "#{icons_path}##{name}")
    end
  end
end
