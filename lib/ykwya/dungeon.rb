require_relative 'item'

require_relative 'builders/dungeon-builders'

module YKWYA
  class Level
    ROWS = 23
    COLS = 77

    attr_reader :map, :potions, :monsters, :hoards

    def initialize(terrain_builder, potion_builder, monster_builder,
                   gold_builder)
      @terrain_builder = terrain_builder
      @potion_builder = potion_builder
      @monster_builder = monster_builder
      @gold_builder = gold_builder

      @map = @terrain_builder.build_dungeon
      @potions = initialize_potions
      @monsters = initialize_monsters
      @hoards = initialize_hoards
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

    def initialize_monsters
      monsters = @monster_builder.build_monsters
      monster_spaces = @map.select { |coord, room| room == YKWYA::Empty.new }
                      .keys.sample(monsters.size)

      monster_spaces.zip(monsters).map do |elem|
        elem[0].clone << elem[1]
      end
    end

    def initialize_hoards
      gold = @gold_builder.build_gold
      gold_spaces = @map.select { |coord, room| room == YKWYA::Empty.new }
                       .keys.sample(gold.size)

      gold_spaces.zip(gold).map do |elem|
        elem[0].clone << elem[1]
      end
    end
  end
end
