class Admin::InvitationPolicy < Admin::ApplicationPolicy
  def cancel?
    update?
  end
end
