module HasUsername
  extend ActiveSupport::Concern

  included do
    normalizes :username, with: ->(username) { username.strip.downcase }

    validates :username, presence: true,
                         length: { maximum: 30 },
                         format: { with: /\A[a-z0-9]+\z/ }
  end
end
