require 'rubygems'
require 'httparty'

class ApiCalls
  include HTTParty

  # Get Place ID and Coordinates from Google Places API
  def self.get_place_id_and_coordinates(key, location)
    base_uri 'https://maps.googleapis.com'
    default_params :output => 'json'
    get('/maps/api/place/textsearch/json', :query => {:query => location, :key => key})
  end

  # Get Distance Matrix from OSRM API
  def self.get_matrix(coordinates_string)
    # 100 coordinate max limit from OSRM
    base_uri 'http://router.project-osrm.org'
    default_params :output => 'json'
    @response = get('/table/v1/driving/', :query => {:query => coordinates_string})
    puts "response #{@response}"
  end

end