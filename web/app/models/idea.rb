class Idea < ApplicationRecord
  belongs_to :studio
  belongs_to :writer

  EDITABLE_ATTRIBUTES = %w[title body].freeze

  # 入力欄では Enter で保存するので改行は入らないが、貼り付けると入るため、空白に置き換える
  normalizes :title, :body, with: ->(text) { text.gsub(/\R/, " ") }

  scope :unarchived, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  validate :writer_must_be_studio_member

  def archive!
    update!(archived_at: Time.current)
  end

  def unarchive!
    update!(archived_at: nil)
  end

  private

    def writer_must_be_studio_member
      return if studio.nil? || writer.nil?

      errors.add(:writer, :not_studio_member) unless studio.studio_memberships.exists?(writer:)
    end
end
