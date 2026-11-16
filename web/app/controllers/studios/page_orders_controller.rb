class Studios::PageOrdersController < Studios::BaseController
  def update
    @zine = @studio.zines.find(params.expect(:zine_id))
    authorize [ :studios, @zine ], :update?

    @zine.sort_pages(params.expect(page_ids: []))
    redirect_to studio_zine_pages_path(@studio.slug, @zine), notice: "ページを並べ替えました", status: :see_other
  end
end
