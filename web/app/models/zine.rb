class Zine < ApplicationRecord
  include NormalizesLineBreaks

  belongs_to :studio
  belongs_to :editor, class_name: "Writer"
  has_many :pages, -> { order(:position, :id) }, dependent: :destroy

  # 値は data-theme にそのまま渡すので、daisyUI のテーマ名と一致させる
  # 並び順は選択欄の並び順になる。初期値の retro から明るいテーマを色相の順に並べ、暗いテーマを最後に置く
  enum :theme_color, {
    retro: "retro",
    caramellatte: "caramellatte",
    lemonade: "lemonade",
    cupcake: "cupcake",
    winter: "winter",
    valentine: "valentine",
    cyberpunk: "cyberpunk",
    aqua: "aqua",
    abyss: "abyss",
    coffee: "coffee"
  }, prefix: true, validate: true

  normalizes_line_breaks :description

  validates :title, presence: true,
                    length: { maximum: 30 }
  validates :description, length: { maximum: 200 }
  validate :editor_must_be_studio_member

  def published?
    published_at?
  end

  def publishable?
    pages.exists? && pages.where.not(status: :confirmed).none?
  end

  def sort_pages(page_ids)
    transaction do
      page_ids.each.with_index(1) do |page_id, position|
        pages.find(page_id).update!(position:)
      end
    end
  end

  private

    def editor_must_be_studio_member
      return if studio.nil? || editor.nil?

      errors.add(:editor, :not_studio_member) unless studio.studio_memberships.exists?(writer: editor)
    end
end
