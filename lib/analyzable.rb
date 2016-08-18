module Analyzable
  # Your code goes here!

  # Average price method
  def average_price product_brand_array
  	product_price_array = product_brand_array.collect {|product| product.price}
  	total_price = product_price_array.inject {|memo, price| memo + price}
  	ave_pri = (total_price / product_price_array.length).round(2)
  end
end
