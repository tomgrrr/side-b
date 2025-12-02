<<<<<<< HEAD
=======
require "json"
require "open-uri"

BASE = "https://api.discogs.com"
KEY    = ENV["DISCOGS_KEY"]
SECRET = ENV["DISCOGS_SECRET"]

#50.times do |i|

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


url="#{BASE}/artists/15885/releases?key=#{KEY}&secret=#{SECRET}"

#url= "https://api.discogs.com/database/search?q=nirvana?key=#{KEY}&secret=#{SECRET}"



    user_serialized = URI.parse(url).read
    user = JSON.parse(user_serialized)
    Artist.create(name: user["name"])
    puts Artist.last

    Vinyl.create({
      name: user["title"],
      release_date: user["year"],

    })
>>>>>>> master
