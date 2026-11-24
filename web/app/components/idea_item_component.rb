class IdeaItemComponent < ApplicationComponent
  def initialize(idea:, editing_field: nil)
    unless editing_field.nil? || Idea::EDITABLE_ATTRIBUTES.include?(editing_field)
      raise ArgumentError, "editing_field には #{Idea::EDITABLE_ATTRIBUTES.join(" か ")} を指定してください: #{editing_field.inspect}"
    end

    @idea = idea
    @editing_field = editing_field
  end
end
