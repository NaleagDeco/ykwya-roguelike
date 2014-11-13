require_relative '../item.rb'

module YKWYA
  module Builders
    class PresuppliedDistributionOfGold
      def initialize(num_hoards, distribution)
        @num_hoards = num_hoards
        @distribution = distribution
      end

      def build_gold
        wheel_of_gold = []
        @distribution.each_pair do |gold, points|
          points.times { wheel_of_gold << gold }
        end

        hoards = []
        @num_hoards.times do
          hoards << wheel_of_gold[Random.rand wheel_of_gold.size].new
        end

        hoards
      end
    end

    class NoGold
      def build_gold
        []
      end
    end
  end
end
