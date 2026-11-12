class Administrator < ApplicationRecord
  include UsernameAuthenticatable

  enum :role, { viewer: 0, editor: 1 }, default: :viewer, validate: true
end
