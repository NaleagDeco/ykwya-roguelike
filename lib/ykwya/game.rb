require_relative 'tile'
require_relative 'event'

module YKWYA
  module Game
    DIRECTIONS = [[-1, -1], [-1, 0], [-1, 1],
                  [0, -1], [0, 0], [0, 1],
                  [1, -1], [1, 0], [1, 1]]

    def create_game(player, **builders)
      terrain_builder = builders[:terrain] ||
                        YKWYA::Builders::DungeonFromIO.new(
                          File.open File.expand_path('../../templates/map.txt',
                                                     File.dirname(__FILE__)))
      potion_builder = builders[:potion] ||
                       YKWYA::Builders::UniformlyRandomPotions.new(10)
      monster_builder = monster_builder ||
                        YKWYA::Builders::PresuppliedDistributionOfMonsters.new(
                          20,
                          YKWYA::Werewolf => 4,
                          YKWYA::Vampire => 3,
                          YKWYA::Goblin => 5,
                          YKWYA::Troll => 2,
                          YKWYA::Phoenix => 2,
                          YKWYA::Merchant => 2
                        )
      gold_builder = builders[:gold] ||
                     YKWYA::Builders::PresuppliedDistributionOfGold.new(
                       10,
                       YKWYA::NormalPile => 5,
                       YKWYA::DragonPile => 1,
                       YKWYA::SmallPile => 2
                     )
      terrain = terrain_builder.build_dungeon
      unplaced_monsters = monster_builder.build_monsters
      unplaced_potions = potion_builder.build_potions
      unplaced_gold = gold_builder.build_gold
      # Shuffle to enable random placement
      empty_terrain = terrain.select { |coords, tile| tile.is_a? YKWYA::Empty }
                      .keys.shuffle

      {
        player: player.clone,
        terrain: terrain,
        player_coords: empty_terrain.pop,
        stairway_coords: empty_terrain.pop,
        potions: empty_terrain.pop(unplaced_potions.size)
          .zip(unplaced_potions),
        monsters: empty_terrain.pop(unplaced_monsters.size)
          .zip(unplaced_monsters),
        gold: empty_terrain.pop(unplaced_gold.size).zip(unplaced_gold)
      }
    end

    def neighbourhood(coord)
      offsets = [-1, 0, 1]

      neighbourhood = offsets.repeated_permutation(2).map do |offset|
        coord.zip(offset).map { |elem| elem.inject(:+) }
      end

      neighbourhood - [coord]
    end

    def tick_world(game_state)
      player = game_state[:player].clone
      monsters = game_state[:monsters].select { |monster| !monster.dead? }
                 .map { |monster| monster.map { |elem| elem.clone } }

      attacking = monsters.select do |monster|
        neighbourhood(monster[0]).include? @player_coords
      end.map { |monster| monster.map { |elem| elem.clone } }
      moving = monsters - attacking

      attacking.each do |monster|
        monster[1].fight game_state[:player]
      end

      moving.map! do |monster|
        new_coords = monster[0].zip(DIRECTIONS.sample).map do |coords|
          coords.inject(:+)
        end while @map[new_coords].inaccessible?

        [new_coords, monster[1]]
      end

      {
        player: player,
        terrain: Hash[game_state[:terrain].map { |k, v| {k.clone => v.clone} }],
        player_coords: game_state[:player_coords].clone,
        stairway_coords: game_state[:stairway_coords].clone,
        potions: game_state[:potions].clone,
        monsters: game_state[:monsters],
        gold: game_state[:gold]
      }
    end

    def player_move!(game_state, offset)
      player = game_state[:player].clone
      possible_coords = game_state[:player_coords].zip(offset).map do |elem|
        elem.reduce(:+)
      end

      monsters = game_state[:monsters].map { |m| m.map { |elem| elem.clone } }
                 .group_by { |monster| monster[0] == new_coords }
      monsters[true].each { |monster| player.fight monster[1] }

      new_coords = if monsters.exists_key(true) ||
                      game_state[:terrain][possible_coords].inaccessible?
                     possible_coords.clone
                   else
                     game_state[:player_coords]
                   end

      potions = game_state[:potions].map { |p| p.map { |elem| elem.clone } }
                .group_by { |potion| potion[0] == new_coords }
      potions[true].each { |potion| player.quaff potion[1] }

      gold = game_state[:gold].map { |g| g.map { |elem| elem.clone } }
                .group_by { |g| g[0] == new_coords }
      gold[true].each { |g| player.gain_gold g[1].amount }

      {
        player: player,
        terrain: Hash[game_state[:terrain].map { |k,v| {k.clone => v.clone} }],
        player_coords: new_coords,
        stairway_coords: game_state[:stairway_coords].clone,
        potions: potions[false],
        monsters: monsters[true] + monsters[false],
        gold: gold[false]
      }
    end
  end

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
      @monsters.delete_if { |monster| monster[1].dead? }

      attacking = @monsters.select do |monster|
        neighbourhood(monster[0]).include? @player_coords
      end
      moving = @monsters - attacking

      attacking.each do |monster|
        emit Event.new(:attack, monster[1].fight(@player))
      end

      emit Event.new(:playerdead, nil) if @player.dead?

      moving.map! do |monster|
        new_coords = monster[0].zip(DIRECTIONS.sample).map do |coords|
          coords.inject(:+)
        end while @map[new_coords].inaccessible?

        [new_coords, monster[1]]
      end

      @monsters = attacking + moving
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


        p_idx = @potions.find_index do |potion|
          @player_coords == potion[0]
        end
        if p_idx
          @player.quaff @potions[p_idx][1]
          emit Event.new(:quaffed, @potions[p_idx][1])
          @potions.delete_at p_idx
        end

        g_idx = @hoards.find_index do |hoard|
          @player_coords == hoard[0]
        end
        if g_idx
          true_gain = @player.gain_gold(@hoards[g_idx][1].class.amount)
          emit Event.new(:goldpicked, true_gain)
          @hoards.delete_at g_idx
        end
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

      potion_spaces.zip(potions)
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
