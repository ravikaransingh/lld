# frozen_string_literal: true

# Create a parking lot with 2 levels
require_relative  'level'
require_relative  'parking_lot'
require_relative  'parking_spot'
require_relative  'vehicle'
parking_lot = ParkingLot.new
level1 = Level.new(1, "Level 1", 10)
level2 = Level.new(2, "Level 2", 15)

# Add parking spots to levels
level1.add_spot(ParkingSpot.new(1, "car"))
level1.add_spot(ParkingSpot.new(2, "motorcycle"))
level2.add_spot(ParkingSpot.new(3, "truck"))

# Add levels to parking lot
parking_lot.add_level(level1)
parking_lot.add_level(level2)

# Create a vehicle
vehicle = Vehicle.new(1, "car", "ABC123")

# Park the vehicle
spot = parking_lot.park_vehicle(vehicle)
puts "Vehicle parked at spot ID: #{spot.id}"

# Release the vehicle
parking_lot.release_vehicle(spot)
puts "Vehicle released from spot ID: #{spot.id}"

