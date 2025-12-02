require "json"
require "open-uri"

BASE = "https://api.discogs.com"
KEY    = ENV["DISCOGS_KEY"]
SECRET = ENV["DISCOGS_SECRET"]


artists = ["15885", "81015"]


Vinyl.destroy_all
puts "Nettoyage de la base de données"


artists.each do |artist|
  url = "#{BASE}/artists/#{artist}/releases?type=master&per_page=100&key=#{KEY}&secret=#{SECRET}"
  puts url
  data = JSON.parse(URI.parse(url).read)

    albums_count = 0

  data["releases"].each do |release|
    break if albums_count >= 15

    if release["type"] == "master"
      vinyl = Vinyl.create({
        name: release["title"],
        release_date: release["year"],
        songs: release["ressource_url"]["tracklist"]["title"],
        notes: release["ressource_url"]["notes"],
        image: release["thumb"]
        price: release["ressource_url"]["lowest_price"]
      })

      genre = Genre.create({
        name: release["ressource_url"]["genres"]
      })

      Vinyls_genre.create({
        genre: genre
        vinyl: vinyl
      })
      albums_count += 1
      puts "✓ Album #{albums_count}: #{release['artist']} - #{release['title']} (#{release['year']})"
    end
  end
end

puts "\n✅ Seed terminé !"
