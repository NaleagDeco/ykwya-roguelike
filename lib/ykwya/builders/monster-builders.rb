require_relative '../enemy'

module YKWYA
  module Builders
    class PresuppliedDistributionOfMonsters
      def initialize(num_monsters, distribution)
        @num_monsters = num_monsters
        @distribution = distribution
      end

      def build_monsters
        wheel_of_monster = []
        @distribution.each_pair do |monster, points|
          points.times { wheel_of_monster << monster }
        end

        monsters = []
        @num_monsters.times do
          monsters << wheel_of_monster[Random.rand wheel_of_monster.size].new
        end

        monsters
      end
    end

    class NoMonsters
      def build_monsters
        []
      end
    end
  end
end
