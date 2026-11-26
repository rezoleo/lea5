# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'time_with_relative_tag' do
    travel_to Time.new(2023, 2, 12, 17, 45, 52, 'UTC')

    assert_dom_equal %(<time datetime="2023-01-12T17:45:52Z" title="about 1 month ago">Jan 12, 2023</time>),
                     time_with_relative_tag(1.month.ago)
    assert_dom_equal %(<time datetime="2023-03-12T17:45:52Z" title="in 28 days">Mar 12, 2023</time>),
                     time_with_relative_tag(1.month.from_now)
    assert_dom_equal %(<time datetime="2023-05-12T17:45:52Z" title="in 3 months">May 12, 2023</time>),
                     time_with_relative_tag(3.months.from_now)
  end

  test 'svg_icon_tag' do
    assert_dom_equal '<svg class="size-[1.25em] shrink-0 fill-current"><use href="/icons.svg#icon_plus" /></svg>',
                     svg_icon_tag('icon_plus')
  end

  test 'icon_button only asks for confirmation on delete' do
    assert_dom_equal %(<a class="btn-icon" aria-label="Back" href="/users">#{svg_icon_tag('icon_arrow_left')}</a>),
                     icon_button('icon_arrow_left', '/users', label: 'Back')
    assert_includes icon_button('icon_delete', '/users/1', method: :delete, label: 'Delete'),
                    'data-turbo-confirm="Are you sure?"'
    patch_button = icon_button('icon_edit', '/users/1', method: :patch, label: 'Edit')
    assert_includes patch_button, 'value="patch"'
    assert_not_includes patch_button, 'data-turbo-confirm'
  end
end
