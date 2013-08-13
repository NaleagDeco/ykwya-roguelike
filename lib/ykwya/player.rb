require 'bundler/setup'

class Player
  attr_reader :hitpoints
  attr_reader :attack
  attr_reader :defense
  attr_reader :gold

  def initialize(hp, attack, defense)
    @hitpoints = hp
    @attack = attack
    @defense = defense
    @gold = 0
  end

  def dead?
    @hitpoints <= 0
  end

  def gain_gold gp
    @gold += gp
  end

  def quaff p
    new_attr_val = instance_variable_get(p.attribute) + p.magnitude
    instance_variable_set(p.attribute, new_attr_val)
  end  

  def to_s
    '@'
  end
end

class Orc < Player
  def initialize
    super(180, 30, 25)
  end

  def gain_gold gp
    @gold += (gp / 2)
  end
end

class Human < Player
  def initialize
    super(140, 20, 20)
  end
end

class Dwarf < Player
  def initialize
    super(100, 20, 30)
  end

  def gain_gold gp
    @gold += (2 * gp)
  end
end

class Elf < Player
  def initialize
    super(140, 30, 10)
  end

  def quaff p
    super(Potion.new(p.magnitude.abs, p.attribute))
  end
end

class Game
  def initialize player
    @player = player
  end

  def is_over?
    @player.hitpoints <= 0
  end
end

class Potion
  attr_reader :attribute
  attr_reader :magnitude
  
  def initialize(magnitude, attribute)
    @magnitude = magnitude
    @attribute = attribute
  end
end

class EnemyFactory
  class << self
    [['vampire', 50, 25, 25],
     ['werewolf', 120, 30, 5],
     ['troll', 120, 25, 15],
     ['goblin', 70, 5, 10],
     ['merchant', 30, 70, 5],
     ['dragon', 150, 20, 20],
     ['phoenix', 50, 35, 20]].each do |enemy|
      self.send(:define_method, enemy[0]) do
        Enemy.new(*enemy)
      end
    end
  end
end

class Enemy
  attr_reader :symbol
  attr_reader :hitpoints
  attr_reader :attack
  attr_reader :defense

  def initialize symbol, hitpoints, attack, defense
    @hitpoints = hitpoints
    @attack = attack
    @defense = defense
  end
end
