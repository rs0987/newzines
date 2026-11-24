class ArchivedIdeaItemComponent < ApplicationComponent
  def initialize(idea:)
    @idea = idea
  end

  private

    def confirm_message
      "「#{@idea.title.presence || "タイトルなし"}」を削除します。よろしいですか？"
    end
end
