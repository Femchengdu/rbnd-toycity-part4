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

    if get_data_id.include? product_object.id.to_s
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
    if !get_data_id.include? n.to_s
      raise UdaciDataErrors::ProductNotFoundError, "Invalid product ID"
    else
      product_object_at_n = product_object_array[n - 1]
    end
  end


  # destroy a product with id n
  def self.destroy n
    # Find record to destroy
    destroyed_record = find n
    # Destroy the record
    data_table = CSV.table(@@data_path)
    data_table.delete_if do |row|
      row[:id] == n
    end
    # Write back to the datbase
    File.open(@@data_path, 'w') do |f|
    f.write(data_table.to_csv)
    end
    # Return destroyed record
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
    Product.destroy(id)
    updated_brand = n[:brand] ? n[:brand] : brand
    updated_name = n[:name] ? n[:name] : name
    updated_price = n[:price] ? n[:price] : price
    Product.create(id: id, brand: updated_brand, name: updated_name, price: updated_price)    
  end
end
