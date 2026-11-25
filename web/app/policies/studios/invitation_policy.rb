class Studios::InvitationPolicy < Studios::ApplicationPolicy
  def create?
    record.studio.studio_memberships.exists?(writer: user.writer, role: :owner)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(studio_id: StudioMembership.where(writer: user.writer).select(:studio_id))
    end
  end
end
