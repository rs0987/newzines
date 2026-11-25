class Studios::MembershipsController < Studios::BaseController
  before_action :set_membership, only: %i[edit update]

  def index
    @studio_memberships = policy_scope([ :studios, @studio.studio_memberships ])
                            .includes(writer: :account)
                            .order(:id)
  end

  def edit
    authorize [ :studios, @membership ]
  end

  def update
    authorize [ :studios, @membership ]

    if @membership.update(membership_params)
      redirect_to studio_memberships_path(@studio.slug), notice: "「#{@membership.writer.account.username}」の役割を変更しました", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

    # @studio_membership はログイン中のライターのメンバーシップなので、別の名前にする
    def set_membership
      @membership = @studio.studio_memberships.find(params.expect(:id))
    end

    def membership_params
      params.expect(studio_membership: %i[role])
    end
end
