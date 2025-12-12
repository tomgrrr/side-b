# db/seeds.rb
require "json"
require "open-uri"
require "net/http"
require "base64"
require "uri"

puts "🎵 Début du seed des vinyles...\n\n"

# Configuration APIs
DISCOGS_BASE = "https://api.discogs.com"
SPOTIFY_BASE = "https://api.spotify.com/v1"
SPOTIFY_AUTH = "https://accounts.spotify.com/api/token"

KEY = ENV["DISCOGS_KEY"]
SECRET = ENV["DISCOGS_SECRET"]
SPOTIFY_CLIENT_ID = ENV["SPOTIFY_CLIENT_ID"]
SPOTIFY_CLIENT_SECRET = ENV["SPOTIFY_CLIENT_SECRET"]

# Liste des artistes Discogs
ARTISTS_IDS = ["6197", "40029", "7987", "19731", "137880", "38661", "1778977", "2742944", "321128", "289775", "138556", "3243777", "29735", "92476", "4859364", "66852", "2165577", "125246", "7566127", "3244227", "22854", "1277429", "164263", "282489", "5226023", "2171152", "3310737", "2165577", "792536", "2184482", "5590213", "145288", "106450", "2725", "15228", "251517", "82730", "10584", "31617", "20991", "45", "45467", "205", "1489", "151223", "1289", "81013"] # Travis Scott
MAX_ALBUMS_PER_ARTIST = 60

def clean_artist_name(name)
  # Retire le (2), (3), etc. à la fin du nom
  name.gsub(/\s*\(\d+\)\s*$/, '').strip
end

# Fonction : Obtenir le token Spotify
def get_spotify_token
  uri = URI(SPOTIFY_AUTH)

  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "Basic #{Base64.strict_encode64("#{SPOTIFY_CLIENT_ID}:#{SPOTIFY_CLIENT_SECRET}")}"
  request["Content-Type"] = "application/x-www-form-urlencoded"
  request.body = "grant_type=client_credentials"

  begin
    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true,
      verify_mode: OpenSSL::SSL::VERIFY_NONE # Désactive vérification SSL (dev only)
    ) do |http|
      http.request(request)
    end

    data = JSON.parse(response.body)

    if data["access_token"]
      return data["access_token"]
    else
      puts "❌ Erreur authentification Spotify: #{data['error_description']}"
      return nil
    end
  rescue => e
    puts "❌ Erreur connexion Spotify: #{e.message}"
    return nil
  end
end

# Fonction : Recherche un album sur Spotify
def search_spotify_album(token, artist_name, album_name)
  return nil unless token

  query = "artist:#{artist_name} album:#{album_name}"
  encoded_query = URI.encode_www_form_component(query)
  uri = URI("#{SPOTIFY_BASE}/search?q=#{encoded_query}&type=album&limit=1")

  begin
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{token}"

    response = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true,
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    ) do |http|
      http.request(request)
    end

    data = JSON.parse(response.body)

    if data["albums"] && data["albums"]["items"].any?
      album = data["albums"]["items"][0]
      images = album["images"]

      if images.any?
        image_url = images[0]["url"]
        puts "   ✓ Spotify: #{album['name']} (#{images[0]['width']}x#{images[0]['height']})"
        return image_url
      end
    else
      puts "   ⚠ Pas trouvé sur Spotify"
    end
  rescue => e
    puts "   ⚠ Erreur Spotify: #{e.message}"
  end

  nil
end

# Obtention du token Spotify
puts "🔑 Authentification Spotify..."
spotify_token = get_spotify_token

if spotify_token
  puts "✅ Token Spotify obtenu\n\n"
else
  puts "❌ Impossible d'obtenir le token Spotify. Vérifiez vos credentials."
  exit
end

# Import des vinyles
ARTISTS_IDS.each do |artist_id|

  puts "=" * 80
  puts "🎤 Import de l'artiste Discogs ID: #{artist_id}"
  puts "=" * 80

  url = "#{DISCOGS_BASE}/artists/#{artist_id}/releases?type=master&per_page=100&key=#{KEY}&secret=#{SECRET}"

  begin
    data = JSON.parse(URI.parse(url).read)
    rescue OpenURI::HTTPError => e
      if e.message.include?("502")
        puts "⚠ Discogs renvoie 502, je réessaie dans 60 secondes..."
        sleep(60)
        retry
      else
        raise e
      end
  end

  # Création de l'artiste
  artist_name = data["releases"][0]['artist']
  artist_name = clean_artist_name(artist_name)
  artist = Artist.find_or_create_by!(name: artist_name)
  puts "✅ Artiste créé: #{artist_name}\n\n"

  albums_count = 0

  data["releases"].each do |release|
    sleep(15)
    albums_count += 1
    break if albums_count >= MAX_ALBUMS_PER_ARTIST

    next unless release["type"] == "master"

    album_name = release["title"]
    puts "📀 Album #{albums_count + 1}: #{album_name} (#{release['year']})"

    # Récupère les détails du master depuis Discogs
    url_master = release["resource_url"]

    begin
      data_master = JSON.parse(URI.parse(url_master).read)
      rescue OpenURI::HTTPError => e
        if e.message.include?("502")
          puts "⚠ Discogs renvoie 502 sur master, attente 60s..."
          sleep(60)
          retry
        else
          raise e
        end
    end

    # Extraction des tracks
    tracks = []
    if data_master["tracklist"]
      data_master["tracklist"].each do |t|
        tracks << t["title"]
      end
    end

    # Recherche de la pochette sur Spotify
    puts "   🔍 Recherche cover sur Spotify..."
    image_url = search_spotify_album(spotify_token, artist_name, album_name)

    # Fallback sur le thumb Discogs si pas trouvé
    if image_url.nil?
      puts "   ❌ Aucune image Spotify trouvée → vinyle ignoré\n\n"
      next
    end

    # Création du vinyle
    vinyl = Vinyl.find_or_create_by!({
      name: album_name,
      release_date: release["year"],
      image: image_url,
      songs: tracks,
      notes: data_master["notes"]
    })

    # Genres
    if data_master["genres"]
      data_master["genres"].each do |genre_name|
        genre = Genre.find_or_create_by!(name: genre_name)
        VinylsGenre.find_or_create_by!(genre: genre, vinyl: vinyl)
      end
    end

    # Association artiste-vinyle
    ArtistsVinyl.find_or_create_by!(artist: artist, vinyl: vinyl)

    puts "   ✅ Vinyle créé: #{vinyl.name}"
    puts ""

    # Petit délai pour être poli avec l'API
  end

  puts "✅ #{albums_count} albums importés pour #{artist_name}\n\n"

  sleep(120)
end

puts "=" * 80
puts "🎉 Seed terminé !"
puts "=" * 80
puts "📊 Résumé:"
puts "   - #{Artist.count} artistes"
puts "   - #{Vinyl.count} vinyles"
puts "   - #{Genre.count} genres"
puts "=" * 80

# require "json"
# require "open-uri"
# require "net/http"
# require "base64"
# require "uri"
# require "csv"

# SPOTIFY_BASE = "https://api.spotify.com/v1"
# SPOTIFY_AUTH = "https://accounts.spotify.com/api/token"

# SPOTIFY_CLIENT_ID = ENV["SPOTIFY_CLIENT_ID"]
# SPOTIFY_CLIENT_SECRET = ENV["SPOTIFY_CLIENT_SECRET"]

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

# filepath = "db/data/vinyls.csv"

# token = get_spotify_token

# CSV.foreach(filepath) do |row|
#   begin
#     # Vérification qu’on a le nombre de colonnes attendu
#     unless row.size >= 8
#       puts "⚠️ Ligne ignorée (colonnes insuffisantes) : #{row.inspect}"
#       next
#     end

#     artist_name = row[5]
#     album_name  = row[0]

#     image_url = search_spotify_album(token, artist_name, album_name)

#     if image_url.nil?
#       puts "❌ Image Spotify non trouvée → Album ignoré : #{album_name}"
#       next
#     end

#     artist = Artist.find_or_create_by!(name: artist_name)

#     puts "✅ Spotify OK pour #{album_name} : #{image_url}"

#     vinyl = Vinyl.create!(
#       name: album_name,
#       release_date: row[1],
#       image: image_url,
#       songs: row[3],
#       notes: row[4],
#       price: row[7].to_f.round(2) * 7.5
#     )

#     genre = Genre.find_or_create_by!(name: row[6])
#     VinylsGenre.create!(genre: genre, vinyl: vinyl)
#     ArtistsVinyl.create!(artist: artist, vinyl: vinyl)
#     ArtistGenre.find_or_create_by!(artist: artist, genre: genre)

#     puts "#{artist.name}: #{vinyl.name} → Importé"

#   rescue StandardError => e
#     puts "❌ Erreur sur la ligne #{row.inspect} → #{e.class}: #{e.message}"
#     next
#   end
# end
