# frozen_string_literal: true

require 'thread'

class ParkingLot
  attr_accessor :levels, :entry_points, :mutex

  def initialize
    @levels = []
    @entry_points = []
    @mutex = Mutex.new
  end

  def add_level(level)
    @levels << level
  end

  def add_entry_point(entry_point)
    @entry_points << entry_point
  end

  def find_nearest_spot_for_vehicle(vehicle, entry_point)
    nearest_spot = nil
    nearest_distance = Float::INFINITY

    @levels.each do |level|
      level.available_spots.each do |spot|
        if spot.can_park_vehicle?(vehicle)
          distance = spot.distance_to(entry_point)
          if distance < nearest_distance
            nearest_distance = distance
            nearest_spot = spot
          end
        end
      end
    end

    nearest_spot
  end

  def park_vehicle(vehicle, entry_point)
    @mutex.synchronize do
      spot = find_nearest_spot_for_vehicle(vehicle, entry_point)
      if spot
        spot.park_vehicle(vehicle)
        save_state
        return spot
      else
        raise "No available spot for this vehicle"
      end
    end
  end

  def release_vehicle(spot)
    @mutex.synchronize do
      spot.release_vehicle
      save_state
    end
  end

  def available_spots
    @levels.map(&:available_spots).flatten
  end

  def save_state
    # Implement saving logic here
  end

  def self.from_h(hash)
    # Logic to recreate the ParkingLot object from the hash
  end

  def to_h
    # Convert the ParkingLot object to a hash representation
  end
end


