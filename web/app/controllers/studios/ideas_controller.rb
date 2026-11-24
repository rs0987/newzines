class Studios::IdeasController < Studios::BaseController
  before_action :set_idea, only: %i[edit update]
  before_action :set_field, only: %i[edit update]

  def index
    @ideas = policy_scope([ :studios, @studio.ideas ]).order(:id)
  end

  def create
    @idea = @studio.ideas.build(writer: @studio_membership.writer)
    authorize [ :studios, @idea ]

    @idea.save!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to studio_ideas_path(@studio.slug), status: :see_other }
    end
  end

  def edit
    authorize [ :studios, @idea ]
  end

  def update
    authorize [ :studios, @idea ]

    if @idea.update(idea_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to studio_ideas_path(@studio.slug), status: :see_other }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

    def set_idea
      @idea = @studio.ideas.find(params.expect(:id))
    end

    def set_field
      @field = params.expect(:field)
      raise ActionController::BadRequest unless Idea::EDITABLE_ATTRIBUTES.include?(@field)
    end

    def idea_params
      params.expect(idea: [ @field ])
    end
end
