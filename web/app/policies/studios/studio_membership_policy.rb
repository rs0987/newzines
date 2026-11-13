class Studios::StudioMembershipPolicy < Studios::ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(writer: user.writer)
    end
  end
end
