class FormControlComponent < ViewComponent::Base
  def initialize(form, attribute, label:)
    @form = form
    @attribute = attribute
    @label = label
  end
end
