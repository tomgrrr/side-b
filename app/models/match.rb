class Match < ApplicationRecord
  belongs_to :vinyl
  belongs_to :user
  belongs_to :playlist, optional: true


  def total_value(array)
    total = 0
    array.each do |a|
      total = a.vinyl.price
    end
    total
  end

  def user_taste(matches)
    titles = ""
    genres = ""
    artists = ""

    #matches.each do |match|
     # titles += match.vinyl.title
      #genres += match.vinyl.genre
      #artists += match.vinyl.artist
    #end

  end
end
