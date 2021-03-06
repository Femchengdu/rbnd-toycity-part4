module Analyzable
  # Your code goes here!

  # Average price method
  def average_price product_brand_array
  	product_price_array = product_brand_array.collect {|product| product.price}
  	total_price = product_price_array.inject {|memo, price| memo + price}
  	ave_pri = (total_price / product_price_array.length).round(2)
  end

  # Print report
  def print_report products_array
    report_array = [] 
    report_array << "Average Price: #{average_price products_array}"
   

    report_array << "Inventory by Brand:"
    count_by_brand(products_array).each do |key, value|
      report_array << "  - #{key}: #{value}"
    end

    report_array << "Inventory by Name:"
    count_by_name(products_array).each do |key, value|
      report_array << "  - #{key}: #{value}"
    end
    report_array.join("\n")
  end


  def count_by_brand brand_array
  	brand_count = Hash.new 0
  	brand_array.each do |product|
  		brand_count[product.brand] += 1
  	end
  	brand_count
  end

  def count_by_name name_array
  	count_hash = Hash.new 0
  	name_array.each do |product|
  		count_hash[product.name] += 1
  	end
  	count_hash
  end
end
