class Studios::ZinesController < Studios::BaseController
  before_action :set_zine, only: %i[show edit update destroy]

  def index
    @zines = policy_scope([ :studios, @studio.zines ])
               .includes(editor: :account)
               .order(id: :desc)
               .page(params[:page])
  end

  def show
    authorize [ :studios, @zine ]
  end

  def new
    @zine = @studio.zines.build(editor: @studio_membership.writer)
    authorize [ :studios, @zine ]
  end

  def create
    @zine = @studio.zines.build(zine_params)
    authorize [ :studios, @zine ]

    if @zine.save
      redirect_to studio_zine_path(@studio.slug, @zine), notice: "ZINE を作成しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize [ :studios, @zine ]
  end

  def update
    authorize [ :studios, @zine ]

    if @zine.update(zine_params)
      redirect_to studio_zine_path(@studio.slug, @zine), notice: "ZINE を更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize [ :studios, @zine ]

    @zine.destroy!
    redirect_to studio_zines_path(@studio.slug), notice: "ZINE を削除しました", status: :see_other
  end

  private

    def set_zine
      @zine = @studio.zines.find(params.expect(:id))
    end

    def zine_params
      params.expect(zine: %i[title description editor_id theme_color])
    end
end
