class InvitationStatusBadgeComponent < ApplicationComponent
  STATUSES = {
    pending: { label: "受諾待ち", color: "badge-info" },
    accepted: { label: "受諾済み", color: "badge-success" },
    canceled: { label: "キャンセル済み", color: "badge-neutral" },
    expired: { label: "期限切れ", color: "badge-warning" }
  }.freeze

  def initialize(status:)
    @status = status
  end

  private

    def label
      STATUSES.fetch(@status)[:label]
    end

    def color
      STATUSES.fetch(@status)[:color]
    end
end
