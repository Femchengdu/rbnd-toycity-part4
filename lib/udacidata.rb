require_relative 'find_by'
require_relative 'errors'
require 'csv'

class Udacidata
  # Your code goes here!

  # Create method
  def self.create attributes = nil
    # set the file path
    file = File.dirname(__FILE__) + "/../data/data.csv"
    # create the product object
    product_object = self.new(attributes)
    # check if the entry exists
    if CSV.read(file).include? [product_object.id, product_object.brand, product_object.name, product_object.price]
      #Return product object
      product_object
    else
      # save the product object
      CSV.open(file, 'a') do |csv|
        csv << [product_object.id, product_object.brand, product_object.name, product_object.price ]
      end
      product_object
    end
  end

  # Get all the product objects from the database
  def self.all
  	# Set the file path (Not dry)
    file = File.dirname(__FILE__) + "/../data/data.csv"
    # Empty product object array
    product_object_array = []
    # Read the database with headers option set to ture
    products_array = CSV.read(file, headers: true)
    # Using each to iterate through the records
    products_array.each do |product_row|
      # Set the product attributes
      attributes = {id: product_row['id'].to_i, brand: product_row['brand'], name: product_row['product'], price: product_row['price'].to_f}
      # Create product object
      product_object = self.new attributes
      # Add to product objects array
      product_object_array << product_object
    end
    product_object_array
  end


  # Return the first or first n element in the products array
  def self.first n = nil
    # Get a list of all the products
    product_object_array = all
    if n 
      # get the first(n) products from the products array 
      product_object_array.first(n)
    else
      #get the first product from the products array
      product_object_array.first
    end
  end


  # Return the last or last n element in the products array
  def self.last n = nil
    # Get a list of all the products
    product_object_array = all
    if n 
      # get the last(n) products from the products array 
      product_object_array.last(n)
    else
      #get the last product from the products array
      product_object_array.last
    end
  end


  # Find a product with id n
  def self.find n 
    # Get a list of all the products
    product_object_array = all
    # Get product object at position n-1
    product_object_at_n = product_object_array[n - 1]
  end


  # destroy a product with id n
  def self.destroy n
    # Set the file path (Not dry)
    file = File.dirname(__FILE__) + "/../data/data.csv"
    # Get list of product objects
    products = all
    # Delete from the product objects array
    destroyed_record = products.delete_at n - 1
    # Wipe the database and run the create method with the new array
    CSV.open(file, "wb") do |csv|
      csv << ["id", "brand", "product", "price"]
    end
    products.each do |product_row|
      # Create product attributes hash without id
      attributes = {brand: product_row.brand, name: product_row.name, price: product_row.price.to_f}
      # Recreate product objects from the attributes hash
      product_object = Product.create attributes
    end
    return destroyed_record
  end


  # Find a product with brand name n
  def self.find_by_brand n
    products = all
    products.find {|product| n == product.brand}
  end

  # Find a product with name n
  def self.find_by_name n
    products = all
    products.find {|product| n == product.name}
  end

  # Find all products with brand n
  def self.where n
    products = all
    products.select {|product| product.brand == n}
  end


  # Update product attributes
  def update n
    # Set the file path (Not dry)
    file = File.dirname(__FILE__) + "/../data/data.csv"
    # Get a list of all the products from the database
    products = Product.all
    # Get and set the product attributes
    update_product_id = self.id
    update_product_brand = n[:brand] || self.brand
    update_product_name = n[:name] || self.name
    update_product_price = n[:price] || self.price.to_f
    # Create attributes hash
    update_attributes = {id: update_product_id, brand: update_product_brand, name: update_product_name, price: update_product_price}
    # Create a new product based off the attributes hash
    updated_product = Product.new update_attributes    
    # Update the list of procuts
    updated_products = products.collect {|product| (product.id == updated_product.id) ? updated_product : product}
    # Wipe the database 
    CSV.open(file, "wb") do |csv|
      csv << ["id", "brand", "product", "price"]
    end
    # Write the updated list to the database
    updated_products.each do |product_row|
      # Create product attributes hash with id
      attributes = {id: product_row.id, brand: product_row.brand, name: product_row.name, price: product_row.price.to_f}
      # Recreate product objects from the attributes hash
      product_object = Product.create attributes
    end
    updated_product
  end
end
