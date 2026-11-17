class FieldsetComponent < ApplicationComponent
  def initialize(form, attribute, legend: nil, hint: nil)
    @form = form
    @attribute = attribute
    @legend = legend
    @hint = hint
  end

  private

    def legend
      @legend || @form.object.class.human_attribute_name(@attribute)
    end

    def described_by
      [ (hint_id if @hint), (error_id if errors.any?) ].compact.join(" ").presence
    end

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
