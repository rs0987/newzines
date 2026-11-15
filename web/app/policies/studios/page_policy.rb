class Studios::PagePolicy < Studios::ApplicationPolicy
  def show?
    zine_policy.show?
  end

  def create?
    zine_policy.update?
  end

  def update?
    zine_policy.update?
  end

  def destroy?
    zine_policy.update?
  end

  def write?
    record.writer == user.writer
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(zine_id: Studios::ZinePolicy::Scope.new(user, Zine).resolve.select(:id))
    end
  end

  private

  def zine_policy
    Studios::ZinePolicy.new(user, record.zine)
  end
end
