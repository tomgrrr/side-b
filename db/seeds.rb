require "json"
require "open-uri"

BASE = "https://api.discogs.com"
KEY    = ENV["DISCOGS_KEY"]
SECRET = ENV["DISCOGS_SECRET"]


artists = ["10584"]

VinylsGenre.destroy_all
Vinyl.destroy_all
Artist.destroy_all
Genre.destroy_all
puts "Nettoyage de la base de données"


artists.each do |artist|
  url = "#{BASE}/artists/#{artist}/releases?type=master&per_page=100&key=#{KEY}&secret=#{SECRET}"
  puts url
  data = JSON.parse(URI.parse(url).read)

    albums_count = 0

  data["releases"].each do |release|
    break if albums_count >= 15



    if release["type"] == "master"
      url_album = release["resource_url"]
      data_album = JSON.parse(URI.parse(url_album).read)

      track = []

      data_album["tracklist"].each do |t|
        track << t["title"]
      end

      vinyl = Vinyl.create({
        name: release["title"],
        release_date: release["year"],
        image: release["thumb"],

        songs: track,
        notes: data_album["notes"],
        price: data_album["lowest_price"]
      })

      genre = Genre.create({
        name: data_album["genres"]
      })

      VinylsGenre.create({
        genre: genre,
        vinyl: vinyl
      })

      Artist.create(
        name: release['artist']
      )

      albums_count += 1
      puts "✓ Album #{albums_count}: #{release['artist']} - #{release['title']} (#{release['year']} - (#{release['thumb']}))"



    end
  end
end

puts "\n✅ Seed terminé !"
