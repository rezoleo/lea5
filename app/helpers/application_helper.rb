# frozen_string_literal: true

module ApplicationHelper
  # daisyUI modifier and icon per flash type. Anything unknown is informational.
  FLASH_STYLES = {
    'success' => { class: 'alert-success', icon: 'check' },
    'error' => { class: 'alert-error', icon: 'cross' }
  }.freeze
  DEFAULT_FLASH_STYLE = { class: 'alert-info', icon: 'check' }.freeze
  NAV_LINK_CLASS = 'btn btn-ghost btn-sm shrink-0 aria-[current=page]:bg-base-200 aria-[current=page]:text-primary'

  def flash_style(type)
    FLASH_STYLES.fetch(type.to_s, DEFAULT_FLASH_STYLE)
  end

  def nav_link(text, path)
    link_to text, path, class: NAV_LINK_CLASS, 'aria-current': ('page' if current_page?(path))
  end

  # An icon-only action. GET renders a link; any other method a form button,
  # and DELETE asks for confirmation first.
  def icon_button(icon, target, label:, method: :get, **options)
    options = options.merge(class: class_names('btn-icon', options[:class]), 'aria-label': label)
    return link_to(target, options) { svg_icon_tag(icon) } if method == :get

    options[:data] = { turbo_confirm: 'Are you sure?', **options.fetch(:data, {}) } if method == :delete
    button_to(target, options.merge(method:)) { svg_icon_tag(icon) }
  end

  def time_with_relative_tag(date_or_time)
    time_ago_in_words = if date_or_time > Time.current
                          "in #{time_ago_in_words(date_or_time)}"
                        else
                          "#{time_ago_in_words(date_or_time)} ago"
                        end
    time_tag date_or_time, date_or_time.strftime('%b %d, %Y'), title: time_ago_in_words
  end

  def svg_icon_tag(name, **options)
    icons_path = asset_path 'icons.svg'
    # Sized in em so icons scale with the text they sit next to.
    options[:class] = class_names('size-[1.25em] shrink-0 fill-current', options[:class])
    tag.svg(**options) do
      tag.use(href: "#{icons_path}##{name}")
    end
  end
end
