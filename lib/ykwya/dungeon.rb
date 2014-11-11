require_relative 'item'

require_relative 'builders/dungeon-builders'

module YKWYA
  class Dungeon

    def initialize(builder = nil)
      file = File.open File.expand_path('../../templates/map.txt',
                                        File.dirname(__FILE__))
      builder = builder || YKWYA::Builders::DungeonFromIO.new(file)
      @level = Level.new(builder)
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

    def initialize(builder)
      @builder = builder

      @map = @builder.build_dungeon
      @potions = initialize_potions
    end

    private

    def initialize_potions
      potion_spaces = @map.select { |coord, room| room == YKWYA::Empty.new }
                      .keys.sample(10)

      potion_spaces.map do |coords|
        coords.clone << PotionFactory.restore_health
      end
    end
  end
end
