require 'rubygems'
require 'httparty'
require 'open3'
require 'json'

class ApiCalls
  include HTTParty
  include Open3
  include JSON

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
    @response = get("/table/v1/driving/#{coordinates_string}")
    @durations = @response["durations"]
    return @durations
  end

  def self.python_google_or_tools(data_hash)
    json = JSON.dump(data_hash)
    
    # block form
    # Open3.popen3("python ./ortools_d/examples/python/delete_me.py"){|stdin, stdout, stderr, wait_thr|
    Open3.popen3("python #{ENV['PYTHONPATH']}"){|stdin, stdout, stderr, wait_thr|
      pid = wait_thr[:pid]
      stdin.write(json)
      stdin.close()
      stderr.close()
      exit_status = wait_thr.value
      pythondata = stdout.read()
      json = JSON.parse(pythondata)
    }
    return json
  end
  
end