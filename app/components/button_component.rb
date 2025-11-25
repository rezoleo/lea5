# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  include ApplicationHelper

  erb_template <<-ERB
    <%= button_to(
      @path,
      method: @method,
      class: button_class,
      'aria-label': @aria_label,
      data: @data,
      form: @form,
    ) do %>
      <%= @label %>
      <% if @action %>
        <%= svg_icon_tag button_action_icon %>
      <% end %>
    <% end %>
  ERB

  def initialize( # rubocop:disable Metrics/ParameterLists
    label:,
    path:,
    method: :get,
    class_name: '',
    aria_label: nil,
    data: { turbo: false },
    form: {},
    button_type: :primary,
    action: nil
  )
    super
    @label = label
    @path = path
    @method = method
    @class_name = class_name
    @aria_label = aria_label || label
    @data = data
    @form = form
    @button_type = button_type
    @action = action
  end

  def button_class
    base_class = 'button'
    type_class = case @button_type
                 when :primary
                   'button-primary'
                 when :secondary
                   'button-secondary'
                 else
                   ''
                 end
    [base_class, type_class, @class_name].compact.join(' ')
  end

  def button_action_icon
    case @action
    when :add
      'icon_plus'
    when :edit
      'icon_edit'
    when :delete
      'icon_delete'
    else
      ''
    end
  end
end
