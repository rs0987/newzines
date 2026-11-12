class Writer < ApplicationRecord
  belongs_to :account

  validates :account, uniqueness: true
end
