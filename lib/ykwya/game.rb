require_relative 'tile'

module YKWYA
  class Game

    attr_reader :map, :potions, :monsters, :hoards

    def initialize(player, input_stream, terrain_builder = nil,
                   potion_builder = nil, monster_builder = nil,
                   gold_builder = nil)
      @player = player

      @terrain_builder = terrain_builder ||
                         YKWYA::Builders::DungeonFromIO.new(
                           File.open File.expand_path('../../templates/map.txt',
                                                      File.dirname(__FILE__)))
      @potion_builder = potion_builder ||
                        YKWYA::Builders::UniformlyRandomPotions.new(10)
      @monster_builder = monster_builder ||
                         YKWYA::Builders::PresuppliedDistributionOfMonsters.new(
                           20,
                           YKWYA::Werewolf => 4,
                           YKWYA::Vampire => 3,
                           YKWYA::Goblin => 5,
                           YKWYA::Troll => 2,
                           YKWYA::Phoenix => 2,
                           YKWYA::Merchant => 2
                         )
      @gold_builder = gold_builder ||
                       YKWYA::Builders::PresuppliedDistributionOfGold.new(
                         10,
                         YKWYA::NormalPile => 5,
                         YKWYA::DragonPile => 1,
                         YKWYA::SmallPile => 2
                       )

      @map = Level.new(@terrain_builder, @potion_builder, @monster_builder,
                       @gold_builder).map
      @potions = Level.new(@terrain_builder, @potion_builder, @monster_builder,
                           @gold_builder).potions
      @monsters = Level.new(@terrain_builder, @potion_builder,
                            @monster_builder, @gold_builder).potions
      @hoards = Level.new(@terrain_builder, @potion_builder,
                          @monster_builder, @gold_builder).hoards

      @player_coords = find_empty_space
      @stairway_coords = find_last_empty_space

      input_stream
        .select { |event| event == :move_left }
        .on_value { |_| player_left! }
      input_stream
        .select { |event| event == :move_right }
        .on_value { |_| player_right! }
      input_stream
        .select { |event| event == :move_up }
        .on_value { |_| player_up! }
      input_stream
        .select { |event| event == :move_down }
        .on_value { |_| player_down! }
      input_stream
        .select { |event| event == :move_downleft }
        .on_value { |_| player_downleft! }
      input_stream
        .select { |event| event == :move_downright }
        .on_value { |_| player_downright! }
      input_stream
        .select { |event| event == :move_upleft }
        .on_value { |_| player_upleft! }
      input_stream
        .select { |event| event == :move_upright }
        .on_value { |_| player_upright! }
    end

    def is_over?
      @player.hitpoints <= 0
    end

    def player_coords
      @player_coords.clone
    end

    def stairway_coords
      @stairway_coords.clone
    end

    def player_left!
      player_move! [0, -1]
    end

    def player_right!
      player_move! [0, 1]
    end

    def player_up!
      player_move! [-1, 0]
    end

    def player_down!
      player_move! [1, 0]
    end

    def player_upleft!
      player_move! [-1, -1]
    end

    def player_upright!
      player_move! [-1, 1]
    end

    def player_downleft!
      player_move! [1, -1]
    end

    def player_downright!
      player_move! [1, 1]
    end

    private

    def player_move!(offset)
      new_coords = @player_coords.zip(offset).map do |elem|
        elem.reduce(:+)
      end
      new_loc = @map[[new_coords[0], new_coords[1]]]

      @player_coords = new_coords unless new_loc.inaccessible?
    end

    def find_empty_space
      @map.select { |k, v| v == YKWYA::Empty.new }.keys[0]
    end

    def find_last_empty_space
      @map.select { |k, v| v == YKWYA::Empty.new }.keys[-1]
    end
  end
end
