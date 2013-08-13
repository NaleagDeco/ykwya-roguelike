require 'bundler/setup'

require_relative '../lib/ykwya/player'

describe 'Player' do
  it "should print itself out as an '@'" do
    Player.new(0,0,0).to_s.should == '@'
  end

  it 'is dead when hitpoints are 0' do
    player = Player.new(0,0,0)
    player.dead?.should be_true
  end
end

describe 'Game' do
  it "should end when the player's health is <= 0" do
    player = Player.new(0,0,0)
    game = Game.new player
    game.is_over?.should be_true
  end
end

describe "Default Race" do
  it "should have an appropriately attr'd Human character" do
    player = Human.new
    player.hitpoints.should be 140
    player.attack.should be 20
    player.defense.should be 20
  end

  it "should be affected by potions" do
    player = Human.new

    old_hp = player.hitpoints
    potion = Potion.new(-10, :@hitpoints)
    player.quaff potion
    new_hp = player.hitpoints
    new_hp.should eq (old_hp + potion.magnitude)

    old_atk = player.attack
    potion = Potion.new(10, :@attack)
    player.quaff potion
    new_atk = player.attack
    new_atk.should eq (old_atk + potion.magnitude)
  end
end

describe "Dwarf Race" do
  it "should have an appropriately attr'd dwarf character." do
    player = Dwarf.new
    player.hitpoints.should be 100
    player.attack.should be 20
    player.defense.should be 30
  end

  it 'should get twice as much gold' do
    player = Dwarf.new
    player.gain_gold 20
    player.gold.should be 40
  end
end

describe "Elven Race" do
  it "should have an appropriately attr'd elf character." do
    player = Elf.new
    player.hitpoints.should be 140
    player.attack.should be 30
    player.defense.should be 10
  end

  it "should have all negative potions reversed" do
    player = Elf.new
    old_hp = player.hitpoints
    potion = Potion.new(-10, :@hitpoints)
    player.quaff potion
    new_hp = player.hitpoints
    new_hp.should eq (old_hp + potion.magnitude.abs)
  end

  it "should treat positive potions normally" do
    player = Elf.new
    old_atk = player.attack
    potion = Potion.new(10, :@attack)
    player.quaff potion
    new_atk = player.attack
    new_atk.should eq (old_atk + potion.magnitude)
  end
end

describe 'Orc Race' do
  it "should have an appropriately attr'd orc character." do
    player = Orc.new
    player.hitpoints.should be 180
    player.attack.should be 30
    player.defense.should be 25
  end

  it 'should get half as much gold' do
    player = Orc.new
    player.gain_gold 20
    player.gold.should be 10
  end
end

describe 'Enemies' do
  def self.it_should_include_a name, hitpoints, attack, defense
    it "should include a #{name}" do
      enemy = EnemyFactory.send(name)
      enemy.hitpoints.should eq hitpoints
      enemy.attack.should eq attack
      enemy.defense.should eq defense
    end
  end
 
  it_should_include_a :vampire, 50, 25, 25
  it_should_include_a :werewolf, 120, 30, 5
  it_should_include_a :troll, 120, 25, 15
  it_should_include_a :goblin, 70, 5, 10
  it_should_include_a :phoenix, 50, 35, 20
  it_should_include_a :merchant, 30, 70, 5
  it_should_include_a :dragon, 150, 20, 20
end
