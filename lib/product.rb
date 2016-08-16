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
      attributes = {id: product_row['id'].to_i, brand: product_row['brand'], name: product_row['product'], price: product_row['price'].to_i}
      # Create product object
      product_object = Product.create attributes
      # Add to product objects array
      product_object_array << product_object
    end
    product_object_array
  end

  # Return the first element in the products array
  def self.first
    # Get a list of all the products
    product_object_array = all
    # get the first product from the products array
    product_object_array.first
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
