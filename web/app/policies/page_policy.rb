class PagePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.confirmed.where(zine: ZinePolicy::Scope.new(user, Zine).resolve)
    end
  end
end
