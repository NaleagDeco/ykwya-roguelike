require_relative 'tile'
require_relative 'event'

module YKWYA
  class GameState
    DIRECTIONS = [[-1, -1], [-1, 0], [-1, 1],
                  [0, -1], [0, 0], [0, 1],
                  [1, -1], [1, 0], [1, 1]]

    def self.create_game(player, **builders)
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
        gold: empty_terrain.pop(unplaced_gold.size).zip(unplaced_gold),
        status: 'Welcome to YKWYA!'
      }
    end

    def self.neighbourhood(coord)
      offsets = [-1, 0, 1]

      neighbourhood = offsets.repeated_permutation(2).map do |offset|
        coord.zip(offset).map { |elem| elem.inject(:+) }
      end

      neighbourhood - [coord]
    end

    def self.tick_world(game_state)
      player = game_state[:player].clone
      monsters = game_state[:monsters].select { |monster| !monster[1].dead? }
                 .map { |monster| monster.map { |elem| elem.clone } }

      attacking = monsters.select do |monster|
        neighbourhood(monster[0]).include? game_state[:player_coords]
      end
      moving = monsters - attacking

      attacking.each do |monster|
        monster[1].fight player
      end

      moving.map! do |monster|
        new_coords = monster[0].zip(DIRECTIONS.sample).map do |coords|
          coords.inject(:+)
        end while game_state[:terrain][new_coords].inaccessible?

        [new_coords, monster[1]]
      end

      {
        player: player,
        terrain: game_state[:terrain].clone,
        player_coords: game_state[:player_coords].clone,
        stairway_coords: game_state[:stairway_coords].clone,
        potions: game_state[:potions].clone,
        monsters: attacking + moving,
        gold: game_state[:gold],
        status: game_state[:status]
      }
    end

    def self.player_move(game_state, offset)
      player = game_state[:player].clone
      status = ''

      possible_coords = game_state[:player_coords].zip(offset).map do |elem|
        elem.reduce(:+)
      end

      monsters = game_state[:monsters].map { |m| m.map { |elem| elem.clone } }
                 .group_by { |monster| monster[0] == possible_coords }
      monsters.fetch(true, []).each do |monster|
        result = player.fight monster[1]
        status << case result[2]
                  when :missed
                    "Player missed #{result[1].object_name}! "
                  when :defeated
                    "Player killed #{result[1].object_name}! "
                  else
                    "Player hit #{result[1].object_name} for #{result[2]} HP! "
                  end
      end

      new_coords = if monsters.key?(true) ||
                      game_state[:terrain][possible_coords].inaccessible?
                     game_state[:player_coords].clone
                   else
                     possible_coords
                   end

      potions = game_state[:potions].map { |p| p.map { |elem| elem.clone } }
                .group_by { |potion| potion[0] == new_coords }
      potions.fetch(true, []).each do |potion|
        player.quaff potion[1]
        status << "Player drank potion for " <<
          "#{potion[1].magnitude} #{potion[1].attribute.to_s[1..-1]}! "
      end

      gold = game_state[:gold].map { |g| g.map { |elem| elem.clone } }
                .group_by { |g| g[0] == new_coords }
      gold.fetch(true, []).each do |g|
        player.gain_gold g[1].class.amount
        status << "Player gained #{g[1].class.amount} gold! "
      end

      {
        player: player,
        terrain: game_state[:terrain].clone,
        player_coords: new_coords,
        stairway_coords: game_state[:stairway_coords].clone,
        potions: potions.fetch(false, []),
        monsters: monsters.fetch(true, []) + monsters.fetch(false, []),
        gold: gold.fetch(false, []),
        status: status.empty? ? game_state[:status] : status
      }
    end

    def self.process_input(game_state, input)
      if game_state[:player].dead?
        game_state[:status] = 'You are dead :('
        return game_state
      end

      case input
      when :move_left
        tick_world player_move(game_state, [0, -1])
      when :move_right
        tick_world player_move(game_state, [0, 1])
      when :move_up
        tick_world player_move(game_state, [-1, 0])
      when :move_down
        tick_world player_move(game_state, [1, 0])
      when :move_upright
        tick_world player_move(game_state, [-1, 1])
      when :move_upleft
        tick_world player_move(game_state, [-1, -1])
      when :move_downright
        tick_world player_move(game_state, [1, 1])
      when :move_downleft
        tick_world player_move(game_state, [1, -1])
      when :wait
        tick_world game_state
      when :quit
        game_state
      else
        game_state
      end
    end
  end
end
