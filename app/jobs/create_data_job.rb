class CreateDataJob < ApplicationJob
  queue_as :default

  require "json"
  require "open-uri"
  require "net/http"
  require "base64"
  require "uri"
  require "csv"

  # API config
  DISCOGS_BASE = "https://api.discogs.com"
  SPOTIFY_BASE = "https://api.spotify.com/v1"
  SPOTIFY_AUTH = "https://accounts.spotify.com/api/token"

  KEY = ENV["DISCOGS_KEY"]
  SECRET = ENV["DISCOGS_SECRET"]
  SPOTIFY_CLIENT_ID = ENV["SPOTIFY_CLIENT_ID"]
  SPOTIFY_CLIENT_SECRET = ENV["SPOTIFY_CLIENT_SECRET"]

  MAX_ALBUMS_PER_ARTIST = 15

  FILE_PATH = Rails.root.join("db/data/artist_id.txt")

  def read_artist_id
    File.read(FILE_PATH).to_i
  end

  def clean_artist_name(name)
    name.gsub(/\s*\(\d+\)\s*$/, '').strip
  end

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



  def perform

    artist_id = ["#{read_artist_id}"]

    Rails.logger.info "#{artist_id}"

    Rails.logger.info "🧹 Nettoyage base…"

    Rails.logger.info "📀 Début import Discogs + Spotify"

    token = get_spotify_token

    artist_id.each do |artist_id|
      url = "#{DISCOGS_BASE}/artists/#{artist_id}/releases?type=master&per_page=100&key=#{KEY}&secret=#{SECRET}"

      Rails.logger.info "#{url}"

      data = JSON.parse(URI.parse(url).read)

      next if data["releases"].blank?

      artist_name = clean_artist_name(data["releases"][0]["artist"])
      albums_count = 0

      csv_path = "db/data/vinyls.csv"

      write_headers = !File.exist?(csv_path)

      data["releases"].each do |release|
        break if albums_count >= MAX_ALBUMS_PER_ARTIST
        next unless release["type"] == "master"

        album_name = release["title"]
        albums_count += 1

        # Details master Discogs
        master = JSON.parse(URI.parse(release["resource_url"]).read)

        tracks = master["tracklist"]&.map { |t| t["title"] } || []

        price = master["lowest_price"]

        price = 0 if price == nil

        # Pochette Spotify
        image_url = search_spotify_album(token, artist_name, album_name)

        Rails.logger.info "✅ Image Spotify trouvée url: #{image_url}"

        if image_url
          Rails.logger.info "✅ Image Spotify trouvée pour #{album_name}"
        else
          Rails.logger.info "⚠️ Image Spotify non trouvée, utilisation de Discogs"
          image_url ||= release["thumb"]
        end

        notes = master["notes"]

      CSV.open(csv_path, "ab") do |csv|
        csv << ["name", "release_date", "image", "songs", "notes", "artist", "genre", "price"] if write_headers



          csv << [
            album_name,
            release["year"],
            image_url,
            tracks.join("|"),
            notes,
            artist_name,
            master["genres"],
            price
          ]
        end
      end

      Rails.logger.info "📄 CSV généré pour #{artist_name}"
    end

    Rails.logger.info "🎉 Import terminé !"
  end
end
