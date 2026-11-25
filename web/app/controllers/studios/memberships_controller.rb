class Studios::MembershipsController < Studios::BaseController
  def index
    @studio_memberships = policy_scope([ :studios, @studio.studio_memberships ])
                            .includes(writer: :account)
                            .order(:id)
  end
end
