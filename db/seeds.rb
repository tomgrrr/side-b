# # db/seeds.rb
# require "json"
# require "open-uri"
# require "net/http"
# require "base64"
# require "uri"

# puts "🎵 Début du seed des vinyles...\n\n"

# # Configuration APIs
# DISCOGS_BASE = "https://api.discogs.com"
# SPOTIFY_BASE = "https://api.spotify.com/v1"
# SPOTIFY_AUTH = "https://accounts.spotify.com/api/token"

# KEY = ENV["DISCOGS_KEY"]
# SECRET = ENV["DISCOGS_SECRET"]
# SPOTIFY_CLIENT_ID = ENV["SPOTIFY_CLIENT_ID"]
# SPOTIFY_CLIENT_SECRET = ENV["SPOTIFY_CLIENT_SECRET"]

# # Liste des artistes Discogs
# ARTISTS_IDS = ["2742944"] # Travis Scott
# MAX_ALBUMS_PER_ARTIST = 15

# Nettoyage
puts "🧹 Nettoyage de la base de données..."
Match.destroy_all
ArtistsVinyl.destroy_all
ArtistGenre.destroy_all
VinylsGenre.destroy_all
Vinyl.destroy_all
Artist.destroy_all
Genre.destroy_all
puts "✅ Base nettoyée\n\n"


# def clean_artist_name(name)
#   # Retire le (2), (3), etc. à la fin du nom
#   name.gsub(/\s*\(\d+\)\s*$/, '').strip
# end

# # Fonction : Obtenir le token Spotify
# def get_spotify_token
#   uri = URI(SPOTIFY_AUTH)

#   request = Net::HTTP::Post.new(uri)
#   request["Authorization"] = "Basic #{Base64.strict_encode64("#{SPOTIFY_CLIENT_ID}:#{SPOTIFY_CLIENT_SECRET}")}"
#   request["Content-Type"] = "application/x-www-form-urlencoded"
#   request.body = "grant_type=client_credentials"

#   begin
#     response = Net::HTTP.start(
#       uri.hostname,
#       uri.port,
#       use_ssl: true,
#       verify_mode: OpenSSL::SSL::VERIFY_NONE # Désactive vérification SSL (dev only)
#     ) do |http|
#       http.request(request)
#     end

#     data = JSON.parse(response.body)

#     if data["access_token"]
#       return data["access_token"]
#     else
#       puts "❌ Erreur authentification Spotify: #{data['error_description']}"
#       return nil
#     end
#   rescue => e
#     puts "❌ Erreur connexion Spotify: #{e.message}"
#     return nil
#   end
# end

# # Fonction : Recherche un album sur Spotify
# def search_spotify_album(token, artist_name, album_name)
#   return nil unless token

#   query = "artist:#{artist_name} album:#{album_name}"
#   encoded_query = URI.encode_www_form_component(query)
#   uri = URI("#{SPOTIFY_BASE}/search?q=#{encoded_query}&type=album&limit=1")

#   begin
#     request = Net::HTTP::Get.new(uri)
#     request["Authorization"] = "Bearer #{token}"

#     response = Net::HTTP.start(
#       uri.hostname,
#       uri.port,
#       use_ssl: true,
#       verify_mode: OpenSSL::SSL::VERIFY_NONE
#     ) do |http|
#       http.request(request)
#     end

#     data = JSON.parse(response.body)

#     if data["albums"] && data["albums"]["items"].any?
#       album = data["albums"]["items"][0]
#       images = album["images"]

#       if images.any?
#         image_url = images[0]["url"]
#         puts "   ✓ Spotify: #{album['name']} (#{images[0]['width']}x#{images[0]['height']})"
#         return image_url
#       end
#     else
#       puts "   ⚠ Pas trouvé sur Spotify"
#     end
#   rescue => e
#     puts "   ⚠ Erreur Spotify: #{e.message}"
#   end

#   nil
# end

# # Obtention du token Spotify
# puts "🔑 Authentification Spotify..."
# spotify_token = get_spotify_token

# if spotify_token
#   puts "✅ Token Spotify obtenu\n\n"
# else
#   puts "❌ Impossible d'obtenir le token Spotify. Vérifiez vos credentials."
#   exit
# end

# # Import des vinyles
# ARTISTS_IDS.each do |artist_id|
#   puts "=" * 80
#   puts "🎤 Import de l'artiste Discogs ID: #{artist_id}"
#   puts "=" * 80

#   url = "#{DISCOGS_BASE}/artists/#{artist_id}/releases?type=master&per_page=100&key=#{KEY}&secret=#{SECRET}"
#   data = JSON.parse(URI.parse(url).read)

#   # Création de l'artiste
#   artist_name = data["releases"][0]['artist']
#   artist_name = clean_artist_name(artist_name)
#   artist = Artist.create!(name: artist_name)
#   puts "✅ Artiste créé: #{artist_name}\n\n"

#   albums_count = 0

#   data["releases"].each do |release|
#     break if albums_count >= MAX_ALBUMS_PER_ARTIST

#     next unless release["type"] == "master"

#     album_name = release["title"]
#     puts "📀 Album #{albums_count + 1}: #{album_name} (#{release['year']})"

#     # Récupère les détails du master depuis Discogs
#     url_master = release["resource_url"]
#     data_master = JSON.parse(URI.parse(url_master).read)

#     # Extraction des tracks
#     tracks = []
#     if data_master["tracklist"]
#       data_master["tracklist"].each do |t|
#         tracks << t["title"]
#       end
#     end

#     # Recherche de la pochette sur Spotify
#     puts "   🔍 Recherche cover sur Spotify..."
#     image_url = search_spotify_album(spotify_token, artist_name, album_name)

#     # Fallback sur le thumb Discogs si pas trouvé
#     if image_url.nil?
#       puts "   ⚠ Utilise le thumb Discogs"
#       image_url = release["thumb"]
#     end

#     # Création du vinyle
#     vinyl = Vinyl.create!({
#       name: album_name,
#       release_date: release["year"],
#       image: image_url,
#       songs: tracks,
#       notes: data_master["notes"]
#     })

#     # Genres
#     if data_master["genres"]
#       data_master["genres"].each do |genre_name|
#         genre = Genre.find_or_create_by!(name: genre_name)
#         VinylsGenre.create!(genre: genre, vinyl: vinyl)
#       end
#     end

#     # Association artiste-vinyle
#     ArtistsVinyl.create!(artist: artist, vinyl: vinyl)

#     albums_count += 1
#     puts "   ✅ Vinyle créé: #{vinyl.name}"
#     puts ""

#     # Petit délai pour être poli avec l'API
#     sleep(0.5)
#   end

#   puts "✅ #{albums_count} albums importés pour #{artist_name}\n\n"
# end

# puts "=" * 80
# puts "🎉 Seed terminé !"
# puts "=" * 80
# puts "📊 Résumé:"
# puts "   - #{Artist.count} artistes"
# puts "   - #{Vinyl.count} vinyles"
# puts "   - #{Genre.count} genres"
# puts "=" * 80

require "csv"

filepath = "db/data/vinyls.csv"

CSV.foreach(filepath) do |row|

  artist = Artist.find_or_create_by!(name: row[5])

  vinyl = Vinyl.create!({
      name: row[0],
      release_date: row[1],
      image: row[2],
      songs: row[3],
      notes: row[4]
  })

  genre = Genre.find_or_create_by!(name: row[6])

  VinylsGenre.create!(genre: genre, vinyl: vinyl)

  ArtistsVinyl.create!(artist: artist, vinyl: vinyl)

  ArtistGenre.find_or_create_by!(artist: artist, genre: genre)
end
