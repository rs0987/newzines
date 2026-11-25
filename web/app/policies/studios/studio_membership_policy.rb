class Studios::StudioMembershipPolicy < Studios::ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(studio_id: StudioMembership.where(writer: user.writer).select(:studio_id))
    end
  end
end
