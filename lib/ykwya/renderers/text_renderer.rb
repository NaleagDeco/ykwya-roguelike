module YKWYA
  module Renderer
    
    class TextRenderer
      @@glyphs = {
                  'Merchant' => 'M'
                 }
      
      def render object
        @@glyphs[object.class.name]
      end
    end
    
  end
end
