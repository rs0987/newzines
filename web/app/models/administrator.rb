class Administrator < ApplicationRecord
  devise :database_authenticatable, :validatable

  enum :role, { viewer: 0, editor: 1 }, default: :viewer, validate: true

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-z0-9]+\z/ }

  # email 列を持たないため、validatable のメールアドレスのチェックを止める
  def email_required? = false
  def will_save_change_to_email? = false
end
