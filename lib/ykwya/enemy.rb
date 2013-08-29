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
  include GamePiece

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
