require_relative 'udacidata'

class Product < Udacidata
  attr_reader :id, :price, :brand, :name

  def initialize(opts={})

    # Get last ID from the database if ID exists
    get_last_id
    # Set the ID if it was passed in, otherwise use last existing ID
    @id = opts[:id] ? opts[:id].to_i : @@count_class_instances
    # Increment ID by 1
    auto_increment if !opts[:id]
    # Set the brand, name, and price normally
    @brand = opts[:brand]
    @name = opts[:name]
    @price = opts[:price]
  end

  # Create method
  def self.create attributes = nil
    # set the file path
    file = File.dirname(__FILE__) + "/../data/data.csv"
    # create the product object
    product_object = Product.new(attributes)
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

  # List all the products
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
      product_object = Product.create attributes
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
      attributes = {brand: product_row.brand, name: product_row.name, price: product_row.price.to_i}
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
    # Get and set the product attributes
    update_product_id = self.id
    update_product_brand = n[:brand] || self.brand
    update_product_name = n[:name] || self.name
    update_product_price = n[:price] || self.price.to_f
    # Create attributes hash
    update_attributes = {id: update_product_id, brand: update_product_brand, name: update_product_name, price: update_product_price}
    # Create a new product based off the attributes hash
    updated_product = Product.new update_attributes
    # Get a list of all the products from the database
    products = Product.all
    # Update the list of procuts
    updated_products = products.select {|product| 
      product == products[update_product_id -1] ? updated_product : product
    }
    # Wipe the database
    CSV.open(file, "wb") do |csv|
      csv << ["id", "brand", "product", "price"]
    end
    # Write the updated list to the database
    updated_products.each do |product_row|
      # Using the auto incriment fuction, hopefully the database is intact.
      # Create product attributes hash without id
      attributes = {brand: product_row.brand, name: product_row.name, price: product_row.price.to_i}
      # Recreate product objects from the attributes hash
      product_object = Product.create attributes
    end
    updated_product
  end


  private

    # Reads the last line of the data file, and gets the id if one exists
    # If it exists, increment and use this value
    # Otherwise, use 0 as starting ID number
    def get_last_id
      file = File.dirname(__FILE__) + "/../data/data.csv"
      last_id = File.exist?(file) ? CSV.read(file).last[0].to_i + 1 : nil
      @@count_class_instances = last_id || 0
    end

    def auto_increment
      @@count_class_instances += 1
    end
end
