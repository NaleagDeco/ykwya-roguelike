require 'spec_helper'

describe 'Player' do
  it "should print itself out as an '@'" do
    Player.new(0,0,0).to_s.should == '@'
  end

  it 'is dead when hitpoints are 0' do
    player = Player.new(0,0,0)
    player.dead?.should be_true
  end

  it 'should gain 1 gold when most enemies are killed' do
    player = Player.new(1, 10, 10)
    monster = Enemy.new(:test, 'T', 1, 0, 0)

    old_gold = player.gold
    player.fight monster while not monster.dead?
    player.gold.should eq(old_gold + 1)
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
    new_hp.should eq(old_hp + potion.magnitude)

    old_atk = player.attack
    potion = Potion.new(10, :@attack)
    player.quaff potion
    new_atk = player.attack
    new_atk.should eq(old_atk + potion.magnitude)
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
    new_hp.should eq(old_hp + potion.magnitude.abs)
  end

  it "should treat positive potions normally" do
    player = Elf.new
    old_atk = player.attack
    potion = Potion.new(10, :@attack)
    player.quaff potion
    new_atk = player.attack
    new_atk.should eq(old_atk + potion.magnitude)
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

describe 'EnemyFactory' do
  def self.it_should_include_a name, symbol, hitpoints, attack, defense
    it "should include a #{name}" do
      enemy = EnemyFactory.send(name)
      enemy.to_s.should eq symbol
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

describe "Text-based UI" do
  before(:all) do
    @renderer = TextRenderer.new
  end

  def self.glyph_represents glyph, object
    it('should represent ' + object.class.name + 'with the glyph \''+ glyph + '\'') do
      object.render_by(@renderer).should eq glyph
    end
  end

  glyph_represents 'M', Merchant.new
end
