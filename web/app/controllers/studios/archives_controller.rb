class Studios::ArchivesController < Studios::BaseController
  def create
    @idea = @studio.ideas.unarchived.find(params.expect(:idea_id))
    authorize [ :studios, @idea ], :update?

    @idea.archive!
    redirect_to studio_ideas_path(@studio.slug), notice: "ネタをアーカイブしました", status: :see_other
  end

  def destroy
    @idea = @studio.ideas.archived.find(params.expect(:idea_id))
    authorize [ :studios, @idea ], :update?

    @idea.unarchive!
    redirect_to studio_archived_ideas_path(@studio.slug), notice: "ネタを一覧に戻しました", status: :see_other
  end
end
