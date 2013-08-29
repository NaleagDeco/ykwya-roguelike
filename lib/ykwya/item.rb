module YKWYA
  module Item
    
    class Potion
      attr_reader :attribute
      attr_reader :magnitude
      
      def initialize(magnitude, attribute)
        @magnitude = magnitude
        @attribute = attribute
      end
    end
    
  end
end
