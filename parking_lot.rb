require 'singleton'

class ParkingLot
  include Singleton
  attr_accessor :name, :levels, :available_spots

  def initialize
    @name = 'ABC PARKING'
    @levels = []
    @available_spots = Hash.new(0)  # Initialize counts for vehicle types
  end

  def add_parking_level(level)
    @levels << level
    update_available_spots(level)
  end

  def find_available_spot(vehicle_type)
    @levels.each do |level|
      spot = level.spots.find { |s| s.available? && s.type == vehicle_type }
      return spot if spot
    end
    nil
  end

  def decrement_available_spot(vehicle_type)
    if @available_spots[vehicle_type] > 0
      @available_spots[vehicle_type] -= 1
      notify_customers
    else
      puts "No available spots for #{vehicle_type} to decrement."
    end
  end

  def increment_available_spot(vehicle_type)
    @available_spots[vehicle_type] += 1
    notify_customers
  end

  def notify_customers
    puts "Real-time Spot Availability: #{@available_spots}"
  end

  private

  def update_available_spots(level)
    level.spots.each do |spot|
      @available_spots[spot.type] += 1 if spot.available?
    end
    notify_customers
  end
end

class ParkingLevel
  attr_accessor :id, :spots

  def initialize(id)
    @id = id
    @spots = []
  end

  def add_spot(spot)
    @spots << spot
  end
end

class Spot
  attr_accessor :id, :type, :available, :vehicle_number

  def initialize(id, type)
    @id = id
    @type = type
    @available = true
  end

  def available?
    @available
  end

  def reserved(vehicle_number)
    @vehicle_number = vehicle_number
    @available = false
  end

  def released
    @vehicle_number = nil
    @available = true
  end
end

class EntryGate
  def initialize(number, lot)
    @mutex = Mutex.new
    @number = number
    @lot = lot
  end

  attr_accessor :number, :lot

  def vehicle_entry(vehicle_number, type)
    @mutex.synchronize do
      spot = lot.find_available_spot(type)
      raise 'No available spot for this vehicle type' unless spot

      # Mark the spot as occupied
      spot.reserved(vehicle_number)
      lot.decrement_available_spot(type)
    end
  end
end

class ExitGate
  attr_accessor :id, :lot, :number

  def initialize(id, lot)
    @id = id
    @mutex = Mutex.new
    @lot = lot
  end

  def release(vehicle_number)
    @mutex.synchronize do
      # Find the spot assigned to the vehicle
      spot = @lot.levels.flat_map(&:spots).find { |s| s.vehicle_number == vehicle_number }

      raise 'Spot not found or vehicle is not parked' unless spot

      # Mark the spot as available
      spot.released
      lot.increment_available_spot(spot.type)

      puts "Vehicle #{vehicle_number} has exited and spot #{spot.id} is now available."
    end
  end
end

# Create the parking lot instance
parking_lot = ParkingLot.instance
level_1 = ParkingLevel.new(1)
level_2 = ParkingLevel.new(2)

[level_1, level_2].each do |level|
  %w[SMALL MEDIUM LARGE LARGER].each do |type|
    (1..5).each do |spot_number|
      spot = Spot.new(spot_number, type)
      level.add_spot(spot)
    end
  end
end

parking_lot.add_parking_level(level_1)
parking_lot.add_parking_level(level_2)

gate1 = EntryGate.new(1, parking_lot)
gate2 = EntryGate.new(2, parking_lot)
exit_1 = ExitGate.new(1, parking_lot)
exit2 = ExitGate.new(2, parking_lot)

# Simulate a vehicle entry
gate1.vehicle_entry(1, 'SMALL')

# Simulate a vehicle exit
exit2.release(1)
