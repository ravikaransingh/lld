# frozen_string_literal: true

# id (Primary Key)
# vehicle_type (String): Type of the vehicle (e.g., "car", "motorcycle", "truck").
#   license_plate (String): Unique identifier for the vehicle.

class Vehicle
  attr_accessor :id, :vehicle_type, :license_plate

  def initialize(id, vehicle_type, license_plate)
    @id = id
    @vehicle_type = vehicle_type
    @license_plate = license_plate
  end
end

