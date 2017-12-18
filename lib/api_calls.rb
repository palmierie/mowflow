require 'rubygems'
require 'httparty'

class ApiCalls
  include HTTParty

  # Get Place ID and Coordinates from Google Places API
  def self.get_place_id_and_coordinates(key, location)
    base_uri 'https://maps.googleapis.com'
    default_params :output => 'json'
    get('/maps/api/place/textsearch/json', :query => {:query => location, :key => key})
    # url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{location}&key=#{key}"
    # response = HTTParty.get(url)
    # puts "place ID call: #{response}"
  end

end