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
    assert_dom_equal '<svg><use href="/icons.svg#icon_plus" /></svg>', svg_icon_tag('icon_plus')
  end
end
