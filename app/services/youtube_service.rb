# app/services/youtube_service.rb
require 'httparty'

class YoutubeService
  include HTTParty
  base_uri 'https://www.googleapis.com/youtube/v3'

  default_timeout 10

  def self.search_album(artist_name, album_name)
    api_key = ENV['YOUTUBE_API_KEY']

    unless api_key.present?
      Rails.logger.error("❌ YouTube API Key not configured")
      Rails.logger.error("💡 Add YOUTUBE_API_KEY to your .env file")
      return []
    end

    queries = [
      "#{artist_name} #{album_name} full album",
      "#{artist_name} #{album_name} album"
    ]

    queries.each do |query|
      results = perform_search(query, api_key)
      return results if results.present?
    end

    Rails.logger.warn("⚠️  No YouTube videos found for '#{artist_name} - #{album_name}'")
    []
  end

  private

  def self.perform_search(query, api_key)
    begin
      Rails.logger.info("🔍 Searching YouTube: '#{query}'")

      response = get('/search', {
        query: {
          part: 'snippet',
          q: query,
          type: 'video',
          maxResults: 5,
          key: api_key
        }
      })

      if response.success?
        data = response.parsed_response

        if data['items']&.any?
          videos = data['items'].map do |item|
            {
              video_id: item['id']['videoId'],
              title: item['snippet']['title'],
              thumbnail: item['snippet']['thumbnails']['medium']['url'],
              channel: item['snippet']['channelTitle']
            }
          end

          Rails.logger.info("✅ YouTube: Found #{videos.size} videos")
          return videos
        else
          Rails.logger.warn("⚠️  YouTube: No items in response")
        end
      elsif response.code == 403
        error_msg = response.parsed_response.dig('error', 'message')
        Rails.logger.error("❌ YouTube API 403: #{error_msg}")
        Rails.logger.error("💡 Check your API key and quota at https://console.cloud.google.com")
      else
        Rails.logger.error("❌ YouTube API Error: #{response.code}")
        Rails.logger.error("Response: #{response.body}")
      end

    rescue HTTParty::Error => e
      Rails.logger.error("❌ HTTParty Error: #{e.message}")
    rescue StandardError => e
      Rails.logger.error("❌ YouTube Error: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.first(3).join("\n"))
    end

    nil
  end
end
