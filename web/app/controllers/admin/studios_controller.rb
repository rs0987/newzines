class Admin::StudiosController < Admin::BaseController
  before_action :set_studio, only: %i[show edit update destroy]

  def index
    @studios = policy_scope([ :admin, Studio ]).order(created_at: :desc).page(params[:page])
  end

  def show
    authorize [ :admin, @studio ]
  end

  def new
    @studio = Studio.new
    authorize [ :admin, @studio ]
  end

  def create
    @studio = Studio.new(create_params)
    authorize [ :admin, @studio ]

    if @studio.save
      redirect_to admin_studio_path(@studio), notice: "スタジオを作成しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize [ :admin, @studio ]
  end

  def update
    authorize [ :admin, @studio ]

    if @studio.update(update_params)
      redirect_to admin_studio_path(@studio), notice: "スタジオを更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize [ :admin, @studio ]

    @studio.destroy!
    redirect_to admin_studios_path, notice: "スタジオを削除しました", status: :see_other
  end

  private

    def set_studio
      @studio = Studio.find(params.expect(:id))
    end

    def create_params
      params.expect(studio: %i[name slug])
    end

    # slug は attr_readonly で、作成後に代入すると例外になるため、更新では受け取らない
    def update_params
      params.expect(studio: %i[name])
    end
end
