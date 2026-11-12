module UsernameAuthenticatable
  extend ActiveSupport::Concern
  include HasUsername

  included do
    devise :database_authenticatable, :validatable

    validates :username, uniqueness: true

    # email 列を持たないため、validatable のメールアドレスのチェックを止める
    # モジュールのメソッドにすると、後から include される Devise の Validatable に上書きされるため、クラスに直接定義する
    def email_required? = false
    def will_save_change_to_email? = false
  end
end
