require 'ykwya/game-piece'

module YKWYA
  module Item

    class Potion
      include GamePieceMixin

      attr_reader :attribute
      attr_reader :magnitude

      def initialize(magnitude, attribute)
        @magnitude = magnitude
        @attribute = attribute
      end
    end

    class Gold
      include GamePieceMixin
    end

  end
end
