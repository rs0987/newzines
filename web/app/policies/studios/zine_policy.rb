class Studios::ZinePolicy < Studios::ApplicationPolicy
  def show?
    studio_member?
  end

  def create?
    studio_member?
  end

  def update?
    studio_member? && !record.published?
  end

  def destroy?
    studio_member? && !record.published?
  end

  def publish?
    zine_editor? && !record.published? && record.publishable?
  end

  def unpublish?
    zine_editor? && record.published?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(studio_id: StudioMembership.where(writer: user.writer).select(:studio_id))
    end
  end

  private

    def zine_editor?
      record.editor == user.writer
    end

    def studio_member?
      record.studio.studio_memberships.exists?(writer: user.writer)
    end
end
