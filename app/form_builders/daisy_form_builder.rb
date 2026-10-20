# frozen_string_literal: true

# Adds the daisyUI classes to every form control, so views only declare the
# fields themselves. Installed as the default builder in config/application.rb.
class DaisyFormBuilder < ActionView::Helpers::FormBuilder
  TEXT_HELPERS = [:date_field, :email_field, :number_field, :password_field, :text_field].freeze
  TEXT_CLASS = { class: 'input w-full' }.freeze
  SELECT_CLASS = { class: 'select w-full' }.freeze
  CHECK_BOX_CLASS = { class: 'checkbox' }.freeze
  LABEL_CLASS = { class: 'label' }.freeze
  SUBMIT_CLASS = { class: 'btn btn-primary' }.freeze

  TEXT_HELPERS.each do |helper|
    define_method(helper) do |method, options = {}|
      super(method, TEXT_CLASS.merge(options))
    end
  end

  def check_box(method, options = {}, *)
    super(method, CHECK_BOX_CLASS.merge(options), *)
  end

  # Signature mirrors Rails' own helper.
  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {}) # rubocop:disable Metrics/ParameterLists
    super(method, collection, value_method, text_method, options, SELECT_CLASS.merge(html_options))
  end

  def label(method, text = nil, options = {}, &)
    super(method, text, LABEL_CLASS.merge(options), &)
  end

  def submit(value = nil, options = {})
    super(value, SUBMIT_CLASS.merge(options))
  end

  # A label stacked on its control: the layout every field in the app uses.
  # Extra positional arguments are forwarded to the helper, which is what
  # collection_select needs for its collection and value/text methods.
  def field(method, helper = :text_field, *, **options)
    control = public_send(helper, method, *, options)
    @template.tag.div(class: 'field') { label(method) + control }
  end
end
