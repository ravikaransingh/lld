# frozen_string_literal: true
# id (Primary Key)
# level_id (Foreign Key): References the Levels table.
#   spot_type (String): Type of vehicle that can occupy the spot (e.g., "car", "motorcycle", "truck").
#   occupied (Boolean): Indicates if the spot is currently occupied.
#   vehicle_id (Foreign Key, Nullable): References the Vehicles table if the spot is occupied.


class ParkingSpot
  attr_accessor :id, :spot_type, :occupied, :vehicle, :distances

  def initialize(id, spot_type)
    @id = id
    @spot_type = spot_type
    @occupied = false
    @vehicle = nil
    @distances = {}  # Stores distances to each entry point
  end

  def park_vehicle(vehicle)
    if can_park_vehicle?(vehicle)
      @occupied = true
      @vehicle = vehicle
    else
      raise "Spot cannot accommodate this vehicle type"
    end
  end

  def release_vehicle
    @occupied = false
    @vehicle = nil
  end

  def can_park_vehicle?(vehicle)
    vehicle.vehicle_type == @spot_type || (vehicle.vehicle_type == "motorcycle" && @spot_type == "car")
  end

  def set_distance(entry_point, distance)
    @distances[entry_point.id] = distance
  end

  def distance_to(entry_point)
    @distances[entry_point.id]
  end
end


