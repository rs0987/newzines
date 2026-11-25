class Studios::InvitationPolicy < Studios::ApplicationPolicy
  def create?
    record.studio.studio_memberships.exists?(writer: user.writer, role: :owner)
  end
end
