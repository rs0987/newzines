class Idea < ApplicationRecord
  belongs_to :studio
  belongs_to :writer

  validate :writer_must_be_studio_member

  private

    def writer_must_be_studio_member
      return if studio.nil? || writer.nil?

      errors.add(:writer, :not_studio_member) unless studio.studio_memberships.exists?(writer:)
    end
end
