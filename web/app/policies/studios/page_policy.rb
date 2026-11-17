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
    page_writer? && record.draft?
  end

  def submit?
    page_writer? && record.draft?
  end

  def confirm?
    zine_editor? && (record.reviewing? || (page_writer? && record.draft?))
  end

  def send_back?
    zine_editor? && (record.reviewing? || record.confirmed?)
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

    def page_writer?
      record.writer == user.writer
    end

    def zine_editor?
      record.zine.editor == user.writer
    end
end
