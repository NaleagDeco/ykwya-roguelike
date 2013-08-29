require 'ykwya/game-piece'

module YKWYA
  module Enemy
    class Enemy
      include GamePieceMixin

      def self.enemy_seed
        [['vampire', 'V', 50, 25, 25],
         ['werewolf', 'W', 120, 30, 5],
         ['troll', 'T', 120, 25, 15],
         ['goblin', 'N', 70, 5, 10],
         ['merchant', 'M', 30, 70, 5],
         ['dragon', 'D', 150, 20, 20],
         ['phoenix', 'X', 50, 35, 20]]
      end
      
      def self.new_class hitpoints, attack, defense
        Class.new(Enemy) do
          @starting_hitpoints = hitpoints
          @starting_attack = attack
          @starting_defense = defense
        end
      end

      class << self
        attr_reader :starting_hitpoints
        attr_reader :starting_attack
        attr_reader :starting_defense
      end

      attr_reader :hitpoints
      attr_reader :attack
      attr_reader :defense

      def initialize
        @hitpoints = self.class.starting_hitpoints
        @attack = self.class.starting_attack
        @defense = self.class.starting_defense
      end

      def dead?
        @hitpoints <= 0
      end
      
      def attacked player
        @hitpoints =- 1
      end
    end

    Enemy.enemy_seed.each do |enemy|
      klass = Enemy.new_class enemy[2], enemy[3], enemy[4]
      const_set(enemy[0].capitalize, klass)
    end
  
    class EnemyFactory
      class << self
        Enemy.enemy_seed.each do |enemy|
          self.send(:define_method, enemy[0]) do
            const_get(enemy[0].capitalize).new
          end
        end
      end
      
      def self.merchant
        return Merchant.new
      end
    end
        
    class Merchant < Enemy
      def hostile?
        $hostile
      end
      
      def attacked player
        super player
        $hostile = true
      end
    end
  end
end
