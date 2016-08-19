class Module
  def create_finder_methods(*attributes)
    # Your code goes here!
    # Hint: Remember attr_reader and class_eval
    attributes.each do |attribute|
    	finder_method = %Q{
    		def self.find_by_#{attribute} value
    			object_array = all
    			object_array.find {|object| value == object.#{attribute}}
    		end
    	}
    	class_eval finder_method
    end
  end
end
