class Studios::PublicationsController < Studios::BaseController
  before_action :set_zine

  def create
    authorize [ :studios, @zine ], :publish?

    @zine.update!(published_at: Time.current)
    redirect_to studio_zine_path(@studio.slug, @zine), notice: "ZINE を発行しました", status: :see_other
  end

  def destroy
    authorize [ :studios, @zine ], :unpublish?

    @zine.update!(published_at: nil)
    redirect_to studio_zine_path(@studio.slug, @zine), notice: "ZINE の発行を取り消しました", status: :see_other
  end

  private

  def set_zine
    @zine = @studio.zines.find(params.expect(:zine_id))
  end
end
