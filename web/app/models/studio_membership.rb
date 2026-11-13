class StudioMembership < ApplicationRecord
  belongs_to :studio
  belongs_to :writer

  enum :role, { member: 0, owner: 1 }, default: :member, validate: true

  validates :writer, uniqueness: { scope: :studio }
end
