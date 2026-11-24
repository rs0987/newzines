class Idea < ApplicationRecord
  belongs_to :studio
  belongs_to :writer

  # 入力欄では Enter で保存するので改行は入らないが、貼り付けると入るため、空白に置き換える
  normalizes :title, :body, with: ->(text) { text.gsub(/\R/, " ") }

  validate :writer_must_be_studio_member

  private

    def writer_must_be_studio_member
      return if studio.nil? || writer.nil?

      errors.add(:writer, :not_studio_member) unless studio.studio_memberships.exists?(writer:)
    end
end
