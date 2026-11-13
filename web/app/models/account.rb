class Account < ApplicationRecord
  include UsernameAuthenticatable

  has_one :writer, dependent: :destroy
end
