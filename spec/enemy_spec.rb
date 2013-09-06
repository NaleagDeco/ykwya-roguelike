require 'spec_helper'

describe 'EnemyFactory' do
  def self.it_should_include_a name, symbol, hitpoints, attack, defense
    it "should include a #{name}" do
      enemy = EnemyFactory.send(name)
      enemy.hitpoints.should eq hitpoints
      enemy.attack.should eq attack
      enemy.defense.should eq defense
    end
  end

  it_should_include_a :vampire, 'V', 50, 25, 25
  it_should_include_a :werewolf, 'W', 120, 30, 5
  it_should_include_a :troll, 'T', 120, 25, 15
  it_should_include_a :goblin, 'N', 70, 5, 10
  it_should_include_a :phoenix, 'X', 50, 35, 20
  it_should_include_a :merchant, 'M', 30, 70, 5
  it_should_include_a :dragon, 'D', 150, 20, 20
end

describe 'Merchants' do
  it 'should all become hostile if the player kills any of them.' do
    m1 = EnemyFactory.merchant
    m2 = EnemyFactory.merchant

    p = Player.new(0,0,0)
    p.fight m1
    m2.hostile?.should be_true
  end
end
