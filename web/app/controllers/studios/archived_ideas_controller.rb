class Studios::ArchivedIdeasController < Studios::BaseController
  def index
    @ideas = policy_scope([ :studios, @studio.ideas.archived ]).order(:id)
  end

  def destroy
    @idea = @studio.ideas.archived.find(params.expect(:id))
    authorize [ :studios, @idea ]

    @idea.destroy!
    redirect_to studio_archived_ideas_path(@studio.slug), notice: "ネタを削除しました", status: :see_other
  end
end
