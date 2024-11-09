# frozen_string_literal: true

class SearchBarComponent < ViewComponent::Base
  include ApplicationHelper
  erb_template <<-ERB
    <%# locals: () -%>
    <%= form_with(url: search_path, method: :get, class: 'search-bar') do |f| %>
        <div class='search-field'>
            <%= f.text_field :q, required: true, placeholder: 'Type your search here...'%>
        </div>
        <%= render(IconButtonComponent.new(path: 'search', action: :search)) %>
    <% end %>
  ERB

  def initialize(
    search_path:,
    method: :get,
    data: { turbo: false },
    placeholder: 'Type your search here...'
  )
    super()
    @search_path = search_path
    @method = method
    @data = data
    @placeholder = placeholder
  end
end
