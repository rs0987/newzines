class Admin::InvitationsController < Admin::BaseController
  before_action :set_studio

  def index
    @invitations = policy_scope([ :admin, @studio.invitations ])
                     .includes(:inviter)
                     .order(created_at: :desc)
                     .page(params[:page])
  end

  def new
    @invitation = @studio.invitations.build
    authorize [ :admin, @invitation ]
  end

  def create
    @invitation = @studio.invitations.build(invitation_params.merge(inviter: current_administrator))
    authorize [ :admin, @invitation ]

    if @invitation.save
      render :create
    else
      render :new, status: :unprocessable_content
    end
  end

  def cancel
    @invitation = @studio.invitations.find(params.expect(:id))
    authorize [ :admin, @invitation ]

    if @invitation.pending?
      @invitation.cancel!
      redirect_to admin_studio_invitations_path(@studio), notice: "招待をキャンセルしました", status: :see_other
    else
      redirect_to admin_studio_invitations_path(@studio), alert: "受諾待ちの招待だけキャンセルできます", status: :see_other
    end
  end

  private

  def set_studio
    @studio = Studio.find(params.expect(:studio_id))
  end

  def invitation_params
    params.expect(invitation: %i[username])
  end
end
