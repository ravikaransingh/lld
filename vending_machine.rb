class Product
  attr_accessor :name, :price, :quantity

  def initialize(name, price, quantity)
    @name = name
    @price = price
    @quantity = quantity
  end

  def decrement_quantity
    raise "Out of stock" if @quantity <= 0
    @quantity -= 1
  end
end


module Denomination
  COINS = [1, 5, 10, 25, 50, 100]  # In cents
  NOTES = [200, 500, 1000, 2000]   # In cents
end


require 'concurrent'

class Inventory
  def initialize
    @products = Concurrent::Hash.new
  end

  def add_product(name, price, quantity)
    @products[name] = Product.new(name, price, quantity)
  end

  def get_product(name)
    @products[name]
  end

  def restock_product(name, quantity)
    @products[name]&.quantity += quantity
  end
end


class VendingMachineState
  def select_product(vending_machine, product_name); end
  def insert_money(vending_machine, amount); end
  def dispense_product(vending_machine); end
end


class IdleState < VendingMachineState
  def select_product(vending_machine, product_name)
    product = vending_machine.inventory.get_product(product_name)
    if product && product.quantity > 0
      vending_machine.selected_product = product
      vending_machine.transition_to(ReadyState.new)
    else
      puts "Product not available or out of stock."
    end
  end
end

class ReadyState < VendingMachineState
  def insert_money(vending_machine, amount)
    vending_machine.total_payment += amount
    if vending_machine.total_payment >= vending_machine.selected_product.price
      vending_machine.transition_to(DispenseState.new)
    else
      puts "Insufficient funds, please insert more money."
    end
  end
end

class DispenseState < VendingMachineState
  def dispense_product(vending_machine)
    vending_machine.selected_product.decrement_quantity
    change = vending_machine.total_payment - vending_machine.selected_product.price
    vending_machine.reset
    vending_machine.transition_to(IdleState.new)
    puts "Product dispensed. Change returned: #{change} cents."
  end
end


require 'singleton'

class VendingMachine
  include Singleton
  attr_accessor :inventory, :current_state, :selected_product, :total_payment

  def initialize
    @inventory = Inventory.new
    @current_state = IdleState.new
    @selected_product = nil
    @total_payment = 0
  end

  def transition_to(state)
    @current_state = state
  end

  def select_product(product_name)
    @current_state.select_product(self, product_name)
  end

  def insert_money(amount)
    @current_state.insert_money(self, amount)
  end

  def dispense_product
    @current_state.dispense_product(self)
  end

  def reset
    @selected_product = nil
    @total_payment = 0
  end
end


class VendingMachineDemo
  def self.run_demo
    vm = VendingMachine.instance

    # Add products to inventory
    vm.inventory.add_product("Soda", 150, 10)
    vm.inventory.add_product("Chips", 100, 5)

    # Select product and insert money
    vm.select_product("Soda")
    vm.insert_money(100)
    vm.insert_money(50)

    # Dispense product
    vm.dispense_product

    # Try to buy an out-of-stock product
    vm.select_product("Chips")
    5.times { vm.insert_money(100); vm.dispense_product }
    vm.select_product("Chips")  # Should indicate out of stock
  end
end

VendingMachineDemo.run_demo

