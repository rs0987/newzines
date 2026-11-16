class Zine < ApplicationRecord
  belongs_to :studio
  belongs_to :editor, class_name: "Writer"
  has_many :pages, -> { order(:position, :id) }, dependent: :destroy

  validates :title, presence: true,
                    length: { maximum: 30 }
  validates :description, length: { maximum: 200 }
  validate :editor_must_be_studio_member

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
