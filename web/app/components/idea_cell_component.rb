class IdeaCellComponent < ApplicationComponent
  def initialize(idea:, field:, editing: false)
    unless Idea::EDITABLE_ATTRIBUTES.include?(field)
      raise ArgumentError, "field には #{Idea::EDITABLE_ATTRIBUTES.join(" か ")} を指定してください: #{field.inspect}"
    end

    @idea = idea
    @field = field
    @editing = editing
  end

  private

    def frame_id
      dom_id(@idea, @field)
    end

    def label
      Idea.human_attribute_name(@field)
    end

    def value
      @idea.public_send(@field)
    end

    def edit_path
      edit_studio_idea_path(@idea.studio.slug, @idea, field: @field)
    end

    def update_path
      studio_idea_path(@idea.studio.slug, @idea, field: @field)
    end
end
