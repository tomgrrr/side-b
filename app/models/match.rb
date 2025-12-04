class Match < ApplicationRecord
  belongs_to :vinyl
  belongs_to :user
  belongs_to :playlist, optional: true

  def total_value(array)
    value = 0

    array.each do |s|
    value += s.vinyl.price if s.vinyl.price.present?
  end

    value
end
end
