class DialogComponent < ApplicationComponent
  def initialize(id:, title:)
    @id = id
    @title = title
  end

  private

    def title_id
      "#{@id}-title"
    end
end
