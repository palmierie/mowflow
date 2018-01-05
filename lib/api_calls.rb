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
    @durations = []
    if @response["code"] == "Ok"
      @durations[0] = "ok"
      @durations[1] = @response["durations"]
    else  
      @durations[0] = "bad"
      @durations[1] = @response["message"]
    end
    return @durations
  end

  def self.python_google_or_tools(data_hash)
    json = JSON.dump(data_hash)
    
    # block form
    Open3.popen3("python #{ENV['PYTHONPATH']}/lib/ortools_d/examples/python/cvrptw_mowflow.py"){|stdin, stdout, stderr, wait_thr|
      pid = wait_thr[:pid]
      stdin.write(json)
      stdin.close()
      stderr.close()
      exit_status = wait_thr.value
      pythondata = stdout.read()
      if pythondata == ""
        json = "Error with Google OR-Tools Script"
      else
        json = JSON.parse(pythondata)
      end
    }
    return json
  end
  
end