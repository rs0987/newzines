class TextAreaFieldComponent < ApplicationComponent
  def initialize(form, attribute, label: nil, hint: nil, **options)
    @form = form
    @attribute = attribute
    @label = label
    @hint = hint
    @options = options
  end

  private

  def text_area_class
    class_names("textarea w-full aria-invalid:border-error", @options[:class])
  end
end
