# frozen_string_literal: true

# Class representing a coffee recipe with ingredients and their quantities
#
# Design for Coffee Vending Machine
# 1. Overview:
#   The Coffee Vending Machine system will be responsible for offering various types of coffee, managing payments, tracking inventory, and handling multiple user requests concurrently.
#
#   2. System Components:
#               Coffee Machine Interface:
#
#                                Menu Display: Shows available coffee options and prices.
#   User Input Interface: Allows users to select a coffee type and make payments.
#   Payment Processor: Handles user payments and provides change.
#   Dispensing System: Dispenses the selected coffee and handles cup placement.
#   Coffee Recipe Manager:
#
#                   Recipes Storage: Stores recipes for each coffee type, including ingredients and their quantities.
#   Price List: Maintains the pricing information for each coffee type.
#   Inventory Management:
#
#               Ingredient Tracker: Tracks the quantities of each ingredient (e.g., coffee beans, milk, water, sugar).
#   Low Stock Notifier: Sends alerts when ingredients are running low.
#   Concurrency Management:
#
#                 Request Queue: Manages multiple user requests and processes them in order.
#   Thread Safety Mechanisms: Ensures that concurrent access to resources (e.g., ingredient inventory) does not lead to race conditions or inconsistencies.
#   System Controller:
#
#            Operation Orchestrator: Coordinates between various components (user inputs, payment processing, inventory check, and coffee dispensing).
#   Error Handler: Manages errors such as payment failures, out-of-stock scenarios, or machine malfunctions.
#   3. Detailed Design:
#                 Classes and Interfaces:
#
#   CoffeeMachine
#
# Attributes: menu, inventory, paymentProcessor, dispensingSystem
# Methods: displayMenu(), selectCoffee(coffeeType), processPayment(amount), dispenseCoffee(coffeeType), handleRequest(request)
# Coffee
#
# Attributes: name, price, recipe
# Methods: getPrice(), getRecipe()
# Recipe
#
# Attributes: ingredients (a dictionary of ingredient names and quantities)
# Methods: getIngredients()
# Inventory
#
# Attributes: ingredientQuantities (a dictionary)
# Methods: checkIngredientAvailability(recipe), updateInventory(recipe), notifyLowStock()
# PaymentProcessor
#
# Attributes: currentBalance
# Methods: processPayment(amount), provideChange(coffeePrice)
# DispensingSystem
#
# Methods: dispense(coffeeType)
# RequestQueue
#
# Methods: addRequest(request), processNextRequest()
# ThreadSafeLock
#
# Methods: acquire(), release()
# Flow of Operations:
#
#           User Interaction:
#
#   User interacts with the CoffeeMachine interface to select a coffee type.
#     The CoffeeMachine checks the availability of ingredients via the Inventory class.
#       If ingredients are available, the user makes a payment through the PaymentProcessor.
#       The PaymentProcessor handles the transaction, verifies the payment, and returns any necessary change.
#       The DispensingSystem then dispenses the selected coffee.
#       Concurrency Handling:
#
#                     Multiple user requests are handled using the RequestQueue and processed in order.
#       The ThreadSafeLock ensures that inventory checks and updates are thread-safe.
#         Inventory Management:
#
#       The Inventory class monitors ingredient levels and triggers notifyLowStock() when levels fall below a defined threshold.
#         4. Additional Considerations:
#                         Scalability:
#
#         The system should be designed to easily add new coffee types and corresponding recipes.
#           The system can be expanded to support additional payment methods (e.g., mobile payments).
#             Error Handling:
#
#                     The ErrorHandler in the SystemController should provide user-friendly messages and recovery options in case of issues (e.g., retry payment, select another coffee type).
#         Maintenance:
#
#         Regular maintenance routines should be scheduled for cleaning the dispensing system and restocking ingredients.
class Recipe
  attr_reader :ingredients

  def initialize(ingredients)
    @ingredients = ingredients # Hash of ingredient => quantity
  end
end

# Class representing a coffee with its name, price, and recipe
class Coffee
  attr_reader :name, :price, :recipe

  def initialize(name, price, recipe)
    @name = name
    @price = price
    @recipe = recipe
  end
end

# Class to manage the inventory of ingredients
class Inventory
  attr_reader :ingredient_quantities

  def initialize(ingredient_quantities)
    @ingredient_quantities = ingredient_quantities # Hash of ingredient => quantity
  end

  def check_ingredient_availability(recipe)
    recipe.ingredients.all? do |ingredient, quantity|
      @ingredient_quantities[ingredient] && @ingredient_quantities[ingredient] >= quantity
    end
  end

  def update_inventory(recipe)
    recipe.ingredients.each do |ingredient, quantity|
      @ingredient_quantities[ingredient] -= quantity if @ingredient_quantities[ingredient]
    end
  end

  def notify_low_stock
    @ingredient_quantities.each do |ingredient, quantity|
      puts "Low stock: #{ingredient}" if quantity < 10
    end
  end
end

# Class to handle payments and provide change
class PaymentProcessor
  def process_payment(amount, price)
    if amount >= price
      change = amount - price
      puts "Payment successful. Change: $#{change}" if change > 0
      true
    else
      puts "Insufficient funds. Please insert at least $#{price}."
      false
    end
  end
end

# Class responsible for dispensing coffee
class DispensingSystem
  def dispense(coffee)
    puts "Dispensing your #{coffee.name}..."
  end
end

# Main CoffeeMachine class coordinating the different components
class CoffeeMachine
  def initialize(menu, inventory, payment_processor, dispensing_system)
    @menu = menu # Hash of coffee_name => Coffee object
    @inventory = inventory
    @payment_processor = payment_processor
    @dispensing_system = dispensing_system
    @mutex = Mutex.new
  end

  def display_menu
    puts "Available Coffee Options:"
    @menu.each do |name, coffee|
      puts "#{name}: $#{coffee.price}"
    end
  end

  def select_coffee(coffee_name, amount_paid)
    @mutex.synchronize do
      coffee = @menu[coffee_name]
      if coffee
        if @inventory.check_ingredient_availability(coffee.recipe)
          if @payment_processor.process_payment(amount_paid, coffee.price)
            @inventory.update_inventory(coffee.recipe)
            @dispensing_system.dispense(coffee)
          end
        else
          puts "Sorry, we are out of ingredients for #{coffee_name}."
        end
      else
        puts "Invalid selection."
      end
    end
  end
end

# Setting up recipes
espresso_recipe = Recipe.new({ 'coffee beans' => 10, 'water' => 30 })
cappuccino_recipe = Recipe.new({ 'coffee beans' => 8, 'water' => 20, 'milk' => 10 })
latte_recipe = Recipe.new({ 'coffee beans' => 6, 'water' => 20, 'milk' => 15 })

# Setting up coffee menu
menu = {
  'Espresso' => Coffee.new('Espresso', 2.50, espresso_recipe),
  'Cappuccino' => Coffee.new('Cappuccino', 3.00, cappuccino_recipe),
  'Latte' => Coffee.new('Latte', 3.50, latte_recipe)
}

# Initializing inventory
inventory = Inventory.new({ 'coffee beans' => 100, 'water' => 500, 'milk' => 200 })

# Initializing other components
payment_processor = PaymentProcessor.new
dispensing_system = DispensingSystem.new

# Creating Coffee Machine instance
coffee_machine = CoffeeMachine.new(menu, inventory, payment_processor, dispensing_system)

# Simulating user interaction
coffee_machine.display_menu
coffee_machine.select_coffee('Espresso', 3.00)

