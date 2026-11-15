class Page < ApplicationRecord
  belongs_to :zine
  belongs_to :writer

  enum :status, { draft: 0, reviewing: 1, confirmed: 2 }, default: :draft, validate: true

  validates :title, presence: true,
                    length: { maximum: 30 }
  validates :body, length: { maximum: 800 }
end
