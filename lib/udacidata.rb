require_relative 'find_by'
require_relative 'errors'
require 'csv'

class Udacidata
  # Your code goes here!
  @@data_path = File.dirname(__FILE__) + "/../data/data.csv"

  def self.get_data_id 
    database_id_array = []
    CSV.foreach(@@data_path, headers: true) do |row| 
      database_id_array << row['id']
    end
    database_id_array
  end


  # Create method
  def self.create attributes = nil
    # create the product object
    product_object = self.new(attributes)
      #Get list of database id's and check if object id is included in the database
    if get_data_id.include? product_object.id
      product_object
    else
      # save the product object
      CSV.open(@@data_path, 'a') do |csv|
        csv << [product_object.id, product_object.brand, product_object.name, product_object.price]
      end
      product_object
    end
  end

  # Get all the product objects from the database
  def self.all
    # Empty product object array
    product_object_array = []
    # Read the database with headers option set to ture
    CSV.foreach(@@data_path, headers: true) do |row|
      product_object_array << new(id: row['id'].to_i, brand: row['brand'], name: row['product'], price: row['price'].to_f)
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
    if n - 1 > product_object_array.length
      raise UdaciDataErrors::ProductNotFoundError, "Invalid product ID"
    else
      product_object_at_n = product_object_array[n - 1]
    end
  end


  # destroy a product with id n
  def self.destroy n
    # Get list of product objects
    products = all
    # Delete from the product objects array
    if n - 1 > products.length
      raise UdaciDataErrors::ProductNotFoundError, "Invalid product ID"
    else
      destroyed_record = products.delete_at n - 1
    end
    # Wipe the database and run the create method with the new array
    CSV.open(@@data_path, "wb") do |csv|
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

  # create the finder methods
  create_finder_methods :brand, :name

  # Find all products with brand n
  def self.where option_hash
     products = all
    if option_hash[:name]
      products.select {|product| product.send(:name) == option_hash[:name]}
    else
      products.select {|product| product.send(:brand) == option_hash[:brand]}
    end
  end


  # Update product attributes
  def update n
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
    CSV.open(@@data_path, "wb") do |csv|
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
