class ZinePolicy < ApplicationPolicy
  def show?
    record.published_at?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where.not(published_at: nil)
    end
  end
end
