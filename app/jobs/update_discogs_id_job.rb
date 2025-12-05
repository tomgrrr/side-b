class UpdateDiscogsIdJob < ApplicationJob
  queue_as :default

  FILE_PATH = Rails.root.join("db/data/artist_id.txt")

   def read_artist_id
    File.read(FILE_PATH).to_i
  end

  def write_artist_id(new_id)
    File.write(FILE_PATH, new_id.to_s)
  end

  def perform

    new_id = read_artist_id + 1

    write_artist_id(new_id)

  end
end
