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

  def fight monster
    monster.attacked self
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
    [['vampire', 'V', 50, 25, 25],
     ['werewolf', 'W', 120, 30, 5],
     ['troll', 'T', 120, 25, 15],
     ['goblin', 'N', 70, 5, 10],
     #['merchant', 'M', 30, 70, 5],
     ['dragon', 'D', 150, 20, 20],
     ['phoenix', 'X', 50, 35, 20]].each do |enemy|
      self.send(:define_method, enemy[0]) do
        Enemy.new(*enemy)
      end
    end
  end

  def self.merchant
    return Merchant.new
  end
end

class Enemy
  attr_reader :name
  attr_reader :symbol
  attr_reader :hitpoints
  attr_reader :attack
  attr_reader :defense

  def initialize name, symbol, hitpoints, attack, defense
    @name = name
    @hitpoints = hitpoints
    @symbol = symbol
    @attack = attack
    @defense = defense
  end

  def dead?
    @hitpoints <= 0
  end

  def attacked player
    @hitpoints =- 1
    player.gain_gold 1 if dead?
  end

  def to_s
    @symbol
  end
end

class Merchant < Enemy
  def initialize
    super(:merchant, 'M', 30, 70, 5)
  end
  
  def hostile?
    $hostile
  end
  
  def attacked player
    super player
    $hostile = true
  end
end
