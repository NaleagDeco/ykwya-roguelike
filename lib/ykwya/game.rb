require_relative 'tile'
require_relative 'event'

module YKWYA
  class Game
    DIRECTIONS = [[-1, -1], [-1, 0], [-1, 1],
                  [0, -1], [0, 0], [0, 1],
                  [1, -1], [1, 0], [1, 1]]


    attr_reader :map, :potions, :monsters, :hoards, :streams

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

      @map = @terrain_builder.build_dungeon
      @potions = initialize_potions
      @monsters = initialize_monsters
      @hoards = initialize_hoards

      @player_coords = find_empty_space
      @stairway_coords = find_last_empty_space

      @streams = {
        message: Frappuccino::Stream.new(self)
      }

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
      input_stream
        .select { |event| event == :tick }
        .on_value { |_| tick! }
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

    def tick!
      attacking = @monsters.select do |monster|
        neighbourhood(monster[0]).include? @player_coords
      end
      moving = @monsters - attacking

      attacking.each do |monster|
        emit Event.new(:attack, monster[1].fight(@player))
      end

      moving.map! do |monster|
        new_coords = monster[0].zip(DIRECTIONS.sample).map do |coords|
          coords.inject(:+)
        end while @map[new_coords].inaccessible?

        [new_coords, monster[1]]
      end

      @monsters = attacking + moving

      emit Event.new(:playerdead, nil) if @player.dead?
    end

    def neighbourhood(coord)
      offsets = [-1, 0, 1]

      neighbourhood = offsets.repeated_permutation(2).map do |offset|
        coord.zip(offset).map { |elem| elem.inject(:+) }
      end

      neighbourhood - [coord]
    end

    private

    def player_move!(offset)
      new_coords = @player_coords.zip(offset).map do |elem|
        elem.reduce(:+)
      end

      adjacent_monster = @monsters.find do |monster|
        new_coords == monster[0]
      end
      if adjacent_monster
        fight_result = @player.fight(adjacent_monster[1])
        emit Event.new(:attack, fight_result)
        return
      end

      new_loc = @map[[new_coords[0], new_coords[1]]]
      if new_loc.inaccessible?
        emit Event.new(:inaccessible, nil)
      else
        @player_coords = new_coords
      end
    end

    def find_empty_space
      @map.select { |k, v| v == YKWYA::Empty.new }.keys[0]
    end

    def find_last_empty_space
      @map.select { |k, v| v == YKWYA::Empty.new }.keys[-1]
    end

    def initialize_potions
      potions = @potion_builder.build_potions
      potion_spaces = @map.select { |coord, room| room == YKWYA::Empty.new }
                      .keys.sample(potions.size)

      potion_spaces.zip(potions).map
    end

    def initialize_monsters
      monsters = @monster_builder.build_monsters
      monster_spaces = @map.select { |coord, room| room == YKWYA::Empty.new }
                       .keys.sample(monsters.size)

      monster_spaces.zip(monsters)
    end

    def initialize_hoards
      gold = @gold_builder.build_gold
      gold_spaces = @map.select { |coord, room| room == YKWYA::Empty.new }
                    .keys.sample(gold.size)

      gold_spaces.zip(gold)
    end
  end
end
