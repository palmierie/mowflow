# This Python file uses the following encoding: utf-8
# Copyright 2015 Tin Arm Engineering AB
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Capacitated Vehicle Routing Problem with Time Windows (and optional orders).

   This is a sample using the routing library python wrapper to solve a
   CVRPTW problem.
   A description of the problem can be found here:
   http://en.wikipedia.org/wiki/Vehicle_routing_problem.
   The variant which is tackled by this model includes a capacity dimension,
   time windows and optional orders, with a penalty cost if orders are not
   performed.
   Too help explore the problem, two classes are provided Customers() and
   Vehicles(): used to randomly locate orders and depots, and to randomly
   generate demands, time-window constraints and vehicles.
   Distances are computed using the Great Circle distances. Distances are in km
   and times in seconds.

   A function for the displaying of the vehicle plan
   display_vehicle_output

   The optimization engine uses local search to improve solutions, first
   solutions being generated using a cheapest addition heuristic.

"""
import sys
import json
import math
from array import array
from six.moves import xrange
from ortools.constraint_solver import pywrapcp
from ortools.constraint_solver import routing_enums_pb2


def main_test(json_data):
  testobj = {}
  testobj["first_thang"] = json_data
  # return json_data
  return testobj
  # return "method works"
  # return {"method works", json_data}

def distance(x1, y1, x2, y2):
    # Manhattan distance
    dist = abs(x1 - x2) + abs(y1 - y2)

    return dist

# Distance callback
class CreateDistanceCallback(object):
  """Create callback to calculate distances and travel times between points."""

  def __init__(self, locations):
    """Initialize distance array."""
    num_locations = len(locations)
    self.matrix = {}

    for from_node in xrange(num_locations):
      self.matrix[from_node] = {}
      # print ("*************************************************************")
      # print ("In from_node loop matrix [from_node]:", self.matrix[from_node])
      # DELETE LATER ^
      for to_node in xrange(num_locations):
        if from_node == to_node:
          self.matrix[from_node][to_node] = 0
          # print ("In to_node loop matrix [from_node][to_node]:", self.matrix[from_node][to_node])
          # DELETE LATER ^
        else:
          x1 = locations[from_node][0]
          y1 = locations[from_node][1]
          x2 = locations[to_node][0]
          y2 = locations[to_node][1]
          self.matrix[from_node][to_node] = distance(x1, y1, x2, y2)
          # print ("In to_node loop matrix [from_node][to_node]:", self.matrix[from_node][to_node])
          # DELETE LATER ^
  def Distance(self, from_node, to_node):
    return self.matrix[from_node][to_node]


# Distance Matrix callback
class CreateDistanceMatrixCallback(object):
  def __init__(self, locations):
    self.matrix = locations

  def Distance(self, from_node, to_node):
    return self.matrix[from_node][to_node]


# Duration_Per_Location callback
class CreateDurationPerLocationCallback(object):
  """Create callback to get duration_per_location at location node."""

  def __init__(self, duration_per_location):
    self.matrix = duration_per_location

  def Duration_per_location(self, from_node, to_node):
    return self.matrix[from_node]


def main(json_data):
  #Get the data
  location_ids = json_data["location_ids"]
  # locations = json_data["locations"]
  locations = json_data["location_matrix"]
  # sizzee = sys.getsizeof(locations)
  # print (sizzee)
  # return locations
  duration_per_location = json_data["duration_per_location"]
  # Create the data.
  # data
  # location_ids = data["location_ids"]
  # locations = data[1]
  # duration_per_location = data[2]

  # Send data Object
  pythondata = {}

  # num_locations = len(locations)
  num_locations = len(location_ids)

  depot = 0
  num_route_days = 3
  # search_time_limit = 400000

  # Create routing model.
  if num_locations > 0:

    # The number of nodes of the VRP is num_locations.
    # Nodes are indexed from 0 to num_locations - 1. By default the start of
    # a route is node 0.
    routing = pywrapcp.RoutingModel(num_locations, num_route_days, depot)
    search_parameters = pywrapcp.RoutingModel.DefaultSearchParameters()

    # Setting first solution heuristic: the
    # method for finding a first solution to the problem.
    search_parameters.first_solution_strategy = (
        routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC)

    # The 'PATH_CHEAPEST_ARC' method does the following:
    # Starting from a route "start" node, connect it to the node which produces the
    # cheapest route segment, then extend the route by iterating on the last
    # node added to the route.

    # create matrix - not used if matrix imported
    # Put callbacks to the distance function and travel time functions here.

    # dist_between_locations = CreateDistanceCallback(locations)
    # dist_callback = dist_between_locations.Distance
    # routing.SetArcCostEvaluatorOfAllVehicles(dist_callback)
    # create matrix ^ not used if matrix imported

    # get matrix from rubydata
    dist_between_locations = CreateDistanceMatrixCallback(locations)
    dist_callback = dist_between_locations.Distance
    routing.SetArcCostEvaluatorOfAllVehicles(dist_callback)
    # print ("fin programe")
    
    # Put callbacks to the distance function and travel time functions here.

    durations_at_locations = CreateDurationPerLocationCallback(duration_per_location)
    duration_per_location_callback = durations_at_locations.Duration_per_location

    # Adding capacity dimension constraints. Divides total Work available by the number of route days
    WorkCapacity = math.ceil(sum(duration_per_location)/float(num_route_days))+10;
    pythondata['work_cap_per_day'] = WorkCapacity
    # print ("Work Capacity Divided Evenly Per Day", WorkCapacity)
    NullCapacitySlack = 0;
    fix_start_cumul_to_zero = True
    capacity = "Capacity"

    routing.AddDimension(duration_per_location_callback, NullCapacitySlack, WorkCapacity,
                         fix_start_cumul_to_zero, capacity)
    
 
    # Solve displays a solution if any.
    assignment = routing.SolveWithParameters(search_parameters)
    if assignment:
      # data = create_data_array()
      # location_ids = data[0]
      # locations = data[1]
      # duration_per_location = data[2]
      #Get the data
      location_ids = json_data["location_ids"]
      # locations = json_data["locations"]
      locations = json_data["location_matrix"]
      duration_per_location = json_data["duration_per_location"]
      # size = len(locations)
      # DELETED ^
      # Solution cost.
      pythondata['total_distance_all_routes'] = str(assignment.ObjectiveValue()) 
      # print ("Total distance of all routes: " , str(assignment.ObjectiveValue()))
      # Inspect solution.
      capacity_dimension = routing.GetDimensionOrDie(capacity);

      for route_day_num in xrange(num_route_days):
        index = routing.Start(route_day_num)
        # plan_output = 'Route {0}:'.format(route_day_num+1)
        # pythondata["route_day"] = 'Route {0}:'.format(route_day_num+1)
        route_day = 'route_day_{0}'.format(route_day_num+1)
        pythondata[route_day] = {}
        route_list = []
        work_load_list = []
        route_obj = {}

        while not routing.IsEnd(index):
          node_index = routing.IndexToNode(index)
          location_id = location_ids[node_index]
          work_var = capacity_dimension.CumulVar(index)
          route_item = "{location_id}".format(location_id=location_id)
          work_load_item = "{workload}".format(workload=assignment.Value(work_var))
          route_list.append(route_item)
          work_load_list.append(work_load_item)
          index = assignment.Value(routing.NextVar(index))
          # plan_output += \
          #           " {location_id} Work Load({workload}) -> ".format(
          #               location_id=location_id,
          #               workload=assignment.Value(work_var))

        node_index = routing.IndexToNode(index)
        location_id = location_ids[node_index]
        work_var = capacity_dimension.CumulVar(index)
        route_item = "{location_id}".format(location_id=location_id)
        work_load_item = "{workload}".format(workload=assignment.Value(work_var))
        route_list.append(route_item)
        work_load_list.append(work_load_item)

        route_obj = {
                      "location_ids": route_list,
                      "work_load_added": work_load_list
                    }
        pythondata[route_day] = route_obj
        # print (plan_output)
    else:
      # print ('No solution found.')
      pythondata["no_solution"] = "No solution found."
  else:
    # print ('Specify an instance greater than 0.')
    pythondata["no_data"] = "Specify an instance greater than 0."
  return pythondata

# Gets data from Ruby - Sends Data back to Ruby
raw = sys.stdin.read()
rubydata = json.loads(raw)
python_data = main(rubydata)
print (json.dumps(python_data))

# def create_data_array(jsondata):

#   location_ids = jsondata["location_ids"]
#   locations = jsondata["locations"]
#   duration_per_location = jsondata["duration_per_location"]
#   data = [location_ids, locations, duration_per_location]
#   return data

# if __name__ == '__main__':
#   main()
