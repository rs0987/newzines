class Page < ApplicationRecord
  include NormalizesLineBreaks

  belongs_to :zine
  belongs_to :writer

  enum :status, { draft: 0, reviewing: 1, confirmed: 2 }, default: :draft, validate: true

  normalizes_line_breaks :body

  validates :title, presence: true,
                    length: { maximum: 30 }
  validates :body, length: { maximum: 800 }

  before_create :place_at_end

  private

    def place_at_end
      self.position = (zine.pages.maximum(:position) || 0) + 1
    end
end
