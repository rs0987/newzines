class Studio < ApplicationRecord
  has_many :invitations, dependent: :destroy
  has_many :studio_memberships, dependent: :destroy
  has_many :writers, through: :studio_memberships
  has_many :zines, dependent: :destroy

  attr_readonly :slug

  normalizes :slug, with: ->(slug) { slug.strip.downcase }

  validates :name, presence: true,
                   length: { maximum: 30 }
  validates :slug, presence: true,
                   length: { maximum: 30 },
                   uniqueness: true,
                   format: { with: /\A[a-z0-9]+\z/ }
end
