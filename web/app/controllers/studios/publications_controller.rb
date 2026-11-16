class Studios::PublicationsController < Studios::BaseController
  def create
    @zine = @studio.zines.find(params.expect(:zine_id))
    authorize [ :studios, @zine ], :publish?

    @zine.update!(published_at: Time.current)
    redirect_to studio_zine_path(@studio.slug, @zine), notice: "ZINE を発行しました", status: :see_other
  end
end
