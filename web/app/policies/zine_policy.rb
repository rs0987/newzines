class ZinePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where.not(published_at: nil)
    end
  end
end
