require_relative 'game-piece'

module YKWYA
  class Player
    include GamePieceMixin
    include Fightable
    include Fighter

    ## Current hitpoints
    attr_reader :hitpoints

    ## Current attack power
    attr_reader :attack
    ## Current defense power
    attr_reader :defense
    ## Current amount of gold pieces.
    attr_reader :gold

    def initialize(hp, attack, defense)
      @hitpoints = hp
      @attack = attack
      @defense = defense
      @gold = 0
    end

    def gain_gold(gp)
      true_gain = gain_gold_impl gp
      @gold += true_gain
      true_gain
    end

    ##
    # Drink a potion.
    #
    def quaff(p)
      new_attr_val = instance_variable_get(p.attribute) + p.magnitude
      new_attr_val = [0, new_attr_val].max
      instance_variable_set(p.attribute, new_attr_val)
    end

    def fight(monster)
      fight_result = super monster
      self.gain_gold monster.hoard if monster.dead?
      fight_result
    end

    def race
      self.class.name.split('::').last
    end

    def object_name
      'Player'
    end

    private

    def gain_gold_impl(gp)
      gp
    end
  end

  ##
  # Gains gold at twice the half the rate.
  class Orc < Player
    def initialize
      super(180, 30, 25)
    end

    def gain_gold_impl(gp)
      gp / 2
    end
  end

  ##
  # Regular/default player, no special benefits/drawbacks.
  class Human < Player
    def initialize
      super(140, 20, 20)
    end
  end

  ##
  # Gains gold at twice the rate.
  class Dwarf < Player
    def initialize
      super(100, 20, 30)
    end

    private

    def gain_gold_impl(gp)
      2 * gp
    end
  end

  ##
  # Elfs absorb negative potions as if they were positive.
  class Elf < Player
    def initialize
      super(140, 30, 10)
    end

    def quaff(p)
      super(Potion.new(p.magnitude.abs, p.attribute))
    end
  end
end
