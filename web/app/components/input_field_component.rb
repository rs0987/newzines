class InputFieldComponent < ApplicationComponent
  def initialize(form, attribute, label: nil, hint: nil, **options)
    @form = form
    @attribute = attribute
    @label = label
    @hint = hint
    @options = options
  end

  private

  def input_class
    class_names("input w-full aria-invalid:border-error", @options[:class])
  end
end
