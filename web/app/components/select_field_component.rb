class SelectFieldComponent < ApplicationComponent
  def initialize(form, attribute, choices, label: nil, hint: nil, **options)
    @form = form
    @attribute = attribute
    @choices = choices
    @label = label
    @hint = hint
    @options = options
  end

  private

    def select_class
      class_names("select w-full aria-invalid:border-error", @options[:class])
    end
end
