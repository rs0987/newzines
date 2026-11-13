class Writer < ApplicationRecord
  belongs_to :account
  has_many :studio_memberships, dependent: :destroy

  validates :account, uniqueness: true
end
