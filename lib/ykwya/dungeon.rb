require_relative 'item'

require_relative 'builders/dungeon-builders'

module YKWYA
  class Dungeon

    def initialize(terrain_builder = nil, potion_builder = nil)
      file = File.open File.expand_path('../../templates/map.txt',
                                        File.dirname(__FILE__))
      @terrain_builder = terrain_builder ||
                         YKWYA::Builders::DungeonFromIO.new(file)
      @potion_builder = potion_builder ||
                        YKWYA::Builders::UniformlyRandomPotions.new(10)
      @level = Level.new(@terrain_builder, @potion_builder)
    end

    def map
      @level.map
    end

    def potions
      @level.potions
    end
  end

  class Level
    ROWS = 23
    COLS = 77

    attr_reader :map, :potions

    def initialize(terrain_builder, potion_builder)
      @terrain_builder = terrain_builder
      @potion_builder = potion_builder

      @map = @terrain_builder.build_dungeon
      @potions = initialize_potions
    end

    private

    def initialize_potions
      potions = @potion_builder.build_potions
      potion_spaces = @map.select { |coord, room| room == YKWYA::Empty.new }
                      .keys.sample(potions.size)

      potion_spaces.zip(potions).map do |elem|
        elem[0].clone << elem[1]
      end
    end
  end
end
