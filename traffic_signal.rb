# # frozen_string_literal: true
#
# 1. Overview:
#   The Traffic Signal Control System is responsible for managing traffic flow at intersections by controlling signal lights. It ensures safe and efficient transitions between signals, adapts to traffic conditions, and handles emergency situations.
#
#   2. System Components:
#               Signal Controller:
#
#   Signal Types: Manages red, yellow, and green signals.
#   Signal Duration Configurator: Allows configuration and adjustment of signal durations based on traffic data or predefined rules.
#   Transition Handler: Ensures smooth transitions between signals to avoid sudden changes that could lead to accidents.
#   Traffic Detector:
#
#             Traffic Sensors: Detects the volume and flow of traffic at the intersection.
#   Emergency Vehicle Detector: Identifies emergency vehicles approaching the intersection, triggering priority control.
#   Control Logic:
#
#             Signal Timing Algorithm: Determines the optimal duration and order of signals based on current traffic conditions and historical data.
#   Emergency Mode: Overrides normal signal operation to prioritize emergency vehicles, ensuring they pass through the intersection safely and quickly.
#   Adaptive Signal Control: Adjusts signal timings dynamically in response to real-time traffic conditions.
#   User Interface:
#
#          Configuration Panel: Allows operators to set and modify signal timings, emergency protocols, and system parameters.
#   Monitoring Dashboard: Provides real-time visualization of traffic conditions, signal states, and system status.
#   System Controller:
#
#            Central Coordination: Coordinates all components, ensuring the system operates as intended.
#   Error Handling: Detects and manages errors, such as sensor failures or conflicting signals.
#   Scalability Manager: Facilitates the addition of new features, such as integration with smart city infrastructure or support for multiple intersections.
#   3. Detailed Design:
#                 Classes and Interfaces:
#
#   TrafficSignal
#
# Attributes: signal_type (red, yellow, green), duration
# Methods: change_signal(new_signal_type), get_signal_duration()
# SignalController
#
# Attributes: signals (array of TrafficSignal objects), current_signal
# Methods: configure_signal(signal_type, duration), switch_to_next_signal(), handle_transition()
# TrafficDetector
#
# Attributes: traffic_sensors, emergency_vehicle_sensors
# Methods: detect_traffic(), detect_emergency_vehicle()
# ControlLogic
#
# Attributes: signal_timing_algorithm, emergency_mode
# Methods: calculate_optimal_timing(), activate_emergency_mode(), deactivate_emergency_mode()
# UserInterface
#
# Methods: display_dashboard(), configure_system(), monitor_traffic()
# SystemController
#
# Attributes: signal_controller, traffic_detector, control_logic, user_interface
# Methods: initialize_system(), monitor_system(), handle_errors(), expand_system()
# Flow of Operations:
#
#           Normal Operation:
#
#   The TrafficDetector continuously monitors traffic and detects the presence of emergency vehicles.
#     The ControlLogic calculates optimal signal timings using the signal_timing_algorithm and sends instructions to the SignalController.
#     The SignalController manages the transition between signals, adjusting durations as necessary to ensure smooth traffic flow.
#   The UserInterface allows operators to monitor and adjust system settings in real-time.
#   Emergency Handling:
#
#   If an emergency vehicle is detected, the TrafficDetector triggers the emergency_mode in the ControlLogic.
#   The ControlLogic overrides normal signal operations, giving priority to the emergency vehicle.
#   Once the emergency is cleared, the system reverts to normal operation.
#   Configuration and Monitoring:
#
#   System parameters, such as signal durations and emergency protocols, can be configured via the UserInterface.
#   The SystemController continuously monitors system health, traffic conditions, and handles any errors that arise.
#   4. Additional Considerations:
#                   Scalability:
#
#   Design the system to easily integrate additional intersections or new types of sensors (e.g., pedestrian sensors).
#     Support integration with a centralized traffic management system for city-wide coordination.
#   Safety and Reliability:
#
#   Implement fail-safe mechanisms to revert to a default safe state in case of system failures.
#   Ensure redundancy in critical components, such as signal controllers and traffic detectors.
#   Future Enhancements:
#
#            Consider adding machine learning algorithms to predict traffic patterns and optimize signal timings automatically.
#   Integrate with IoT devices for real-time data collection and more responsive traffic management.


# Class representing a traffic signal (red, yellow, green)
class TrafficSignal
  attr_accessor :signal_type, :duration

  def initialize(signal_type, duration)
    @signal_type = signal_type
    @duration = duration
  end

  def change_signal(new_signal_type)
    @signal_type = new_signal_type
  end

  def get_signal_duration
    @duration
  end
end

# Class to manage traffic signals at an intersection
class SignalController
  attr_reader :signals, :current_signal

  def initialize
    @signals = {
      red: TrafficSignal.new('red', 30),
      yellow: TrafficSignal.new('yellow', 5),
      green: TrafficSignal.new('green', 25)
    }
    @current_signal = @signals[:red]
  end

  def configure_signal(signal_type, duration)
    @signals[signal_type.to_sym].duration = duration
  end

  def switch_to_next_signal
    case @current_signal.signal_type
    when 'red'
      @current_signal = @signals[:green]
    when 'green'
      @current_signal = @signals[:yellow]
    when 'yellow'
      @current_signal = @signals[:red]
    end
    handle_transition
  end

  def handle_transition
    puts "Transitioning to #{@current_signal.signal_type} signal."
    sleep(@current_signal.get_signal_duration)
    switch_to_next_signal
  end
end

# Class to detect traffic conditions and emergency vehicles
class TrafficDetector
  def detect_traffic
    # Simulated traffic detection logic
    puts "Detecting traffic..."
    rand(10..50) # Simulated traffic density value
  end

  def detect_emergency_vehicle
    # Simulated emergency vehicle detection
    puts "Checking for emergency vehicles..."
    rand < 0.1 # 10% chance of detecting an emergency vehicle
  end
end

# Class containing control logic for traffic signals
class ControlLogic
  def initialize(signal_controller, traffic_detector)
    @signal_controller = signal_controller
    @traffic_detector = traffic_detector
  end

  def calculate_optimal_timing
    traffic_density = @traffic_detector.detect_traffic
    if traffic_density > 30
      @signal_controller.configure_signal(:green, 40) # Longer green signal for heavy traffic
    else
      @signal_controller.configure_signal(:green, 25)
    end
  end

  def activate_emergency_mode
    if @traffic_detector.detect_emergency_vehicle
      puts "Emergency vehicle detected! Activating emergency mode..."
      @signal_controller.configure_signal(:green, 15) # Short green to quickly clear the way
    else
      puts "No emergency vehicles detected."
    end
  end

  def run
    loop do
      calculate_optimal_timing
      activate_emergency_mode
      @signal_controller.handle_transition
    end
  end
end

# Class for user interface to configure and monitor the system
class UserInterface
  def initialize(signal_controller, control_logic)
    @signal_controller = signal_controller
    @control_logic = control_logic
  end

  def display_dashboard
    puts "Current signal: #{@signal_controller.current_signal.signal_type}, Duration: #{@signal_controller.current_signal.get_signal_duration} seconds"
  end

  def configure_system
    puts "Enter the duration for red signal:"
    red_duration = gets.chomp.to_i
    @signal_controller.configure_signal(:red, red_duration)

    puts "Enter the duration for yellow signal:"
    yellow_duration = gets.chomp.to_i
    @signal_controller.configure_signal(:yellow, yellow_duration)

    puts "Enter the duration for green signal:"
    green_duration = gets.chomp.to_i
    @signal_controller.configure_signal(:green, green_duration)
  end
end

# Main System Controller class to coordinate all components
class SystemController
  def initialize
    @signal_controller = SignalController.new
    @traffic_detector = TrafficDetector.new
    @control_logic = ControlLogic.new(@signal_controller, @traffic_detector)
    @user_interface = UserInterface.new(@signal_controller, @control_logic)
  end

  def initialize_system
    puts "Initializing Traffic Signal Control System..."
    @user_interface.configure_system
    @control_logic.run
  end
end

# Initialize and run the system
system_controller = SystemController.new
system_controller.initialize_system
