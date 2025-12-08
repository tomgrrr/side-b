# app/services/youtube_service.rb
require 'net/http'
require 'json'
require 'uri'

class YoutubeService
  BASE_URL = "https://www.googleapis.com/youtube/v3"

  def self.search_album(artist_name, album_name)
    api_key = ENV['YOUTUBE_API_KEY']

    unless api_key.present?
      Rails.logger.error("YouTube API Key not configured")
      return []
    end

    # Recherche optimisée pour les albums complets
    queries = [
      "#{artist_name} #{album_name} full album",
      "#{artist_name} #{album_name} album"
    ]

    queries.each do |query|
      results = perform_search(query, api_key)
      return results if results.present?
    end

    []
  end

  private

  def self.perform_search(query, api_key)
    encoded_query = URI.encode_www_form_component(query)
    url = "#{BASE_URL}/search?part=snippet&q=#{encoded_query}&type=video&maxResults=5&key=#{api_key}"

    begin
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10

      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)

        if data['items']&.any?
          videos = data['items'].map do |item|
            {
              video_id: item['id']['videoId'],
              title: item['snippet']['title'],
              thumbnail: item['snippet']['thumbnails']['medium']['url'],
              channel: item['snippet']['channelTitle']
            }
          end

          Rails.logger.info("YouTube: Found #{videos.size} videos")
          return videos
        end
      else
        Rails.logger.error("YouTube API Error: #{response.code}")
      end

    rescue StandardError => e
      Rails.logger.error("YouTube Error: #{e.message}")
    end

    nil
  end
end
