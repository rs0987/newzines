class Studios::InvitationsController < Studios::BaseController
  def index
    @invitations = policy_scope([ :studios, @studio.invitations ])
                     .includes(:inviter_administrator, inviter_writer: :account)
                     .order(created_at: :desc)
                     .page(params[:page])
  end

  def new
    @invitation = @studio.invitations.build
    authorize [ :studios, @invitation ]
  end

  def create
    @invitation = @studio.invitations.build(invitation_params.merge(inviter: @studio_membership.writer, role: :member))
    authorize [ :studios, @invitation ]

    if @invitation.save
      render :create
    else
      render :new, status: :unprocessable_content
    end
  end

  private

    def invitation_params
      params.expect(invitation: %i[username])
    end
end
