require "json"
require "open-uri"

BASE = "https://api.discogs.com"
KEY    = ENV["DISCOGS_KEY"]
SECRET = ENV["DISCOGS_SECRET"]


artists = ["15885", "81015"]


Vinyl.destroy_all
puts "Nettoyage de la base de données"

artists.each do |artist|
  url = "https://api.discogs.com/artists/#{artist}/releases?type=master&per_page=50&key=#{KEY}&secret=#{SECRET}"
  user_serialized = URI.parse(url).read
  user = JSON.parse(user_serialized)
  puts user
  # Artist.create(name: user["name"])
  # puts Artist.last

  # Vinyl.create({
  #   name: user["title"],
  #   release_date: user["year"],
  # })
end



  #begin
    #url="#{BASE}/artists/#{i+5000}/releases?key=#{KEY}&secret=#{SECRET}"

    #user_serialized = URI.parse(url).read
    #user = JSON.parse(user_serialized)
    #Artist.create(name: user["name"])
    #puts user
  #rescue
    #puts "error with id:#{i}"
  #end
#end


#url= "https://api.discogs.com/database/search?q=nirvana?key=#{KEY}&secret=#{SECRET}"



    # This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
