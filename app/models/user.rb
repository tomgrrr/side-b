class User < ApplicationRecord
  has_many :chats, dependent: :destroy
  has_one :collection, dependent: :destroy
  has_one :wishlist, dependent: :destroy
  has_one_attached :photo
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, uniqueness: true, presence: true, length: { minimum: 3 }

end
