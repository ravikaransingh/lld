# frozen_string_literal: true

# schema
# id (Primary Key)
# name (String): Name or identifier of the level (e.g., "Level 1", "Level 2").
# total_spots (Integer): Total number of parking spots on this level.
class Level
  attr_accessor :id, :name, :total_spots, :parking_spots

  def initialize(id, name, total_spots)
    @id = id
    @name = name
    @total_spots = total_spots
    @parking_spots = []
  end

  def add_spot(spot)
    @parking_spots << spot
  end

  def available_spots
    @parking_spots.select { |spot| !spot.occupied }
  end
end

