class Studios::IdeaPolicy < Studios::ApplicationPolicy
  def create?
    studio_member?
  end

  def update?
    studio_member?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(studio_id: StudioMembership.where(writer: user.writer).select(:studio_id))
    end
  end

  private

    def studio_member?
      record.studio.studio_memberships.exists?(writer: user.writer)
    end
end
