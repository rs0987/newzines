class FormControlComponent < ViewComponent::Base
  def initialize(form, attribute, label: nil)
    @form = form
    @attribute = attribute
    @label = label
  end
end
