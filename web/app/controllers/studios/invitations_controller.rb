class Studios::InvitationsController < Studios::BaseController
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
