class Invitation < ApplicationRecord
  class NotPendingError < StandardError; end

  include HasUsername

  belongs_to :studio
  belongs_to :inviter, class_name: "Administrator"

  attr_reader :token

  validate :username_not_reserved, on: :create

  before_create :issue_token
  before_create -> { self.expires_at = 7.days.from_now }

  scope :accepted, -> { where.not(accepted_at: nil) }
  scope :pending, -> { where(accepted_at: nil, canceled_at: nil).where(expires_at: Time.current..) }

  def self.find_by_token(token)
    find_by(token_digest: digest(token))
  end

  def self.digest(token)
    Digest::SHA256.hexdigest(token)
  end

  def status
    if accepted_at
      :accepted
    elsif canceled_at
      :canceled
    elsif expires_at.past?
      :expired
    else
      :pending
    end
  end

  def pending?
    status == :pending
  end

  def cancel!
    update!(canceled_at: Time.current)
  end

  def accept(password:)
    account = Account.new(username:, password:)

    transaction do
      lock!
      raise NotPendingError unless pending?

      if account.save
        writer = Writer.create!(account:)
        studio.studio_memberships.create!(writer:, role: :owner)
        update!(accepted_at: Time.current)
      end
    end

    account
  end

  private

    def issue_token
      @token = SecureRandom.urlsafe_base64(32)
      self.token_digest = self.class.digest(@token)
    end

    def username_not_reserved
      return if username.blank?

      reserved = Invitation.pending.or(Invitation.accepted).where(username:)
      errors.add(:username, :taken) if reserved.exists?
    end
end
