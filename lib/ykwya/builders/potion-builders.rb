require_relative '../item'

module YKWYA
  module Builders
    class UniformlyRandomPotions
      def initialize num_potions
        @num_potions = num_potions
      end

      def build_potions
        factory = PotionFactory
        potions = []
        @num_potions.times do
          potions << factory.send(factory.methods(false).sample)
        end

        potions
      end
    end

    class NoPotions
      def build_potions
        []
      end
    end
  end
end
