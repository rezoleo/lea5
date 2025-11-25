# frozen_string_literal: true

# test/components/previews/button_component_preview.rb
class ButtonComponentPreview < ViewComponent::Preview
  # @param label
  def default(label: 'Delete')
    render(ButtonComponent.new(
             label: label,
             path: ''
           ))
  end
end
