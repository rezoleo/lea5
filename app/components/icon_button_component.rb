# frozen_string_literal: true

class IconButtonComponent < ViewComponent::Base
  include ApplicationHelper

  erb_template <<-ERB
    <%= button_to(
      @path,
      method: @method,
      'aria-label': @aria_label,
      data: @data,
      class: 'icon_btn'
    ) do %>
      <%= svg_icon_tag button_action_icon %>
   <% end %>
  ERB

  def initialize(
    path:,
    method: :get,
    data: { turbo: false },
    action: nil,
    aria_label: nil
  )
    super()
    @path = path
    @method = method
    @data = data
    @action = action
    @aria_label = aria_label
  end

  def button_action_icon
    case @action
    when :add
      'icon_plus'
    when :edit
      'icon_edit'
    when :delete
      'icon_delete'
    when :search
      'icon_search'
    else
      ''
    end
  end
end
