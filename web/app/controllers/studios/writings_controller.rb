class Studios::WritingsController < Studios::BaseController
  before_action :set_page

  def edit
    authorize [ :studios, @page ], :write?
  end

  def update
    authorize [ :studios, @page ], :write?

    if @page.update(writing_params)
      redirect_to studio_zine_page_path(@studio.slug, @zine, @page), notice: "ページを保存しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

    def set_page
      @zine = @studio.zines.find(params.expect(:zine_id))
      @page = @zine.pages.find(params.expect(:page_id))
    end

    def writing_params
      params.expect(page: %i[title body])
    end
end
