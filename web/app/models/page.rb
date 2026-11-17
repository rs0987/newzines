class Page < ApplicationRecord
  belongs_to :zine
  belongs_to :writer

  enum :status, { draft: 0, reviewing: 1, confirmed: 2 }, default: :draft, validate: true

  normalizes :body, with: ->(body) { body.gsub("\r\n", "\n") }

  validates :title, presence: true,
                    length: { maximum: 30 }
  validates :body, length: { maximum: 800 }

  before_create :place_at_end

  private

    def place_at_end
      self.position = (zine.pages.maximum(:position) || 0) + 1
    end
end
