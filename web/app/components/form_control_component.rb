class FormControlComponent < ApplicationComponent
  def initialize(form, attribute, label: nil, hint: nil)
    @form = form
    @attribute = attribute
    @label = label
    @hint = hint
  end

  def aria
    described_by = [ (hint_id if @hint), (error_id if errors.any?) ].compact

    { describedby: described_by.join(" ").presence, invalid: (true if errors.any?) }
  end

  private

    def hint_id
      @form.field_id(@attribute, :hint)
    end

    def error_id
      @form.field_id(@attribute, :error)
    end

    def errors
      @form.object&.errors&.full_messages_for(@attribute) || []
    end
end
