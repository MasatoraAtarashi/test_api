class User < ApplicationRecord
  VALID_USER_ID_REGEX = /\A[a-zA-Z0-9]+\z/
  validates :user_id, presence: { message: 'user_id is required' },
                      uniqueness: { message: 'already same user_id is used' },
                      length: { maximum: 20, minimum: 6 },
                      format: { with: VALID_USER_ID_REGEX }
  VALID_PASSWORD_REGEX = /\A[a-zA-Z0-9\/:-@¥\[\-`{-~]+\z/
  validates :password, presence: { message: 'password is required' },
                       length: { maximum: 20, minimum: 8 },
                       format: { with: VALID_PASSWORD_REGEX }
  validates :nickname, length: { maximum: 30 }
  validates :comment, length: { maximum: 100 }
end
