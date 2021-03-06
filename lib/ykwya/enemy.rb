require_relative 'game-piece'

module YKWYA
  ##
  # Killable and (usually) hostile creatures.
  class Enemy
    include GamePieceMixin
    include Fighter
    include Fightable

    ##
    # A list of seeded enemies, defined in the following format:
    #
    # [<name>. <glyph>, <starting hitpoints>, <starting attack strength>,
    # <starting defense strength>]
    def self.enemy_seed
      [['vampire', 50, 25, 25],
       ['werewolf', 120, 30, 5],
       ['troll', 120, 25, 15],
       ['goblin', 70, 5, 10],
       ['merchant', 30, 70, 5],
       ['dragon', 150, 20, 20],
       ['phoenix', 50, 35, 20]]
    end

    ##
    # Helper method for generating classes for seeded enemies.
    def self.new_class hitpoints, attack, defense
      Class.new(Enemy) do
        @starting_hitpoints = hitpoints
        @starting_attack = attack
        @starting_defense = defense
      end
    end

    class << self
      ## Hitpoints a monster of this class should start with.
      attr_reader :starting_hitpoints
      ## Attack strength a monster of this class should start with.
      attr_reader :starting_attack
      ## Defense strength a monster of this class should start with.
      attr_reader :starting_defense
    end

    ## Current hitpoints of this monster.
    attr_reader :hitpoints
    ## Current attack strength of this monster.
    attr_reader :attack
    ## Current defense strength of this monster.
    attr_reader :defense

    def initialize
      @hitpoints = self.class.starting_hitpoints
      @attack = self.class.starting_attack
      @defense = self.class.starting_defense
    end

    ##
    # The amount of gold this monster gives off when killed
    def hoard
      1
    end
  end

  ##
  # We generate a new class for every seed enemy in our array,
  # with the supplied name and starting stats.
  Enemy.enemy_seed.each do |enemy|
    klass = Enemy.new_class enemy[1], enemy[2], enemy[3]
    const_set(enemy[0].capitalize, klass)
  end

  ##
  # The factory we use to generate monsters. Enemies should not be created
  # directly.
  module EnemyFactory
    class << self
      ##
      # We create monsters by calling a method on the enemy factory named after
      # the class of monster.
      Enemy.enemy_seed.each do |enemy|
        self.send(:define_method, enemy[0]) do
          const_get(enemy[0].capitalize).new
        end
      end
    end
  end

  ##
  # Merchants only attack if the player attacks one of their own.
  class Merchant < Enemy
    def hostile?
      $hostile
    end

    def fought_by(belligerent)
      super belligerent
      $hostile = true
    end

    def hoard
      4
    end
  end

  class Dragon < Enemy
    def hoard
      6
    end
  end
end
