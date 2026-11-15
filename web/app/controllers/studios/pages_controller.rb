class Studios::PagesController < Studios::BaseController
  before_action :set_zine
  before_action :set_page, only: %i[show edit update destroy]

  def index
    @pages = policy_scope([ :studios, @zine.pages ])
               .includes(writer: :account)
               .order(:id)
               .page(params[:page])
  end

  def show
    authorize [ :studios, @page ]
  end

  def new
    @page = @zine.pages.build(writer: @studio_membership.writer)
    authorize [ :studios, @page ]
  end

  def create
    @page = @zine.pages.build(page_params)
    authorize [ :studios, @page ]

    if @page.save
      redirect_to studio_zine_page_path(@studio.slug, @zine, @page), notice: "ページを追加しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize [ :studios, @page ]
  end

  def update
    authorize [ :studios, @page ]

    if @page.update(page_params)
      redirect_to studio_zine_page_path(@studio.slug, @zine, @page), notice: "ページを更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize [ :studios, @page ]

    @page.destroy!
    redirect_to studio_zine_pages_path(@studio.slug, @zine), notice: "ページを削除しました", status: :see_other
  end

  private

  def set_zine
    @zine = @studio.zines.find(params.expect(:zine_id))
  end

  def set_page
    @page = @zine.pages.find(params.expect(:id))
  end

  def page_params
    params.expect(page: %i[title writer_id])
  end
end
