require 'spec_helper'

include YKWYA

describe 'Player' do
  it "should print itself out as an '@'" do
    expect(Player.new(0,0,0).to_s).to eq('@')
  end

  it 'is dead when hitpoints are 0' do
    player = Player.new(0,0,0)
    expect(player.dead?).to be(true)
  end

  it 'should gain 1 gold when most enemies are killed' do
    player = Player.new(1, 10, 10)
    monster = YKWYA::Enemy.new_class(1,0,0).new

    old_gold = player.gold
    player.fight monster while not monster.dead?
    expect(player.gold).to eq(old_gold + 1)
  end

  it 'should never get negative have -ive atk/def by drinking a potion' do
    player = Player.new(1, 1, 1)
    curse_attack = Potion.new(-10, :@attack)
    player.quaff curse_attack
    expect(player.attack).to be >= 0

    curse_defense = Potion.new(-10, :@defense)
    player.quaff curse_defense
    expect(player.attack).to be >= 0
  end
end

describe "Default Race" do
  it "should have an appropriately attr'd Human character" do
    player = Human.new
    expect(player.hitpoints).to be 140
    expect(player.attack).to be 20
    expect(player.defense).to be 20
  end

  it "should be affected by potions" do
    player = Human.new

    old_hp = player.hitpoints
    potion = Potion.new(-10, :@hitpoints)
    player.quaff potion
    new_hp = player.hitpoints
    expect(new_hp).to eq(old_hp + potion.magnitude)

    old_atk = player.attack
    potion = Potion.new(10, :@attack)
    player.quaff potion
    new_atk = player.attack
    expect(new_atk).to eq(old_atk + potion.magnitude)
  end
end

describe "Dwarf Race" do
  it "should have an appropriately attr'd dwarf character." do
    player = Dwarf.new
    expect(player.hitpoints).to be 100
    expect(player.attack).to be 20
    expect(player.defense).to be 30
  end

  it 'should get twice as much gold' do
    player = Dwarf.new
    player.gain_gold 20
    expect(player.gold).to be 40
  end
end

describe "Elven Race" do
  it "should have an appropriately attr'd elf character." do
    player = Elf.new
    expect(player.hitpoints).to be 140
    expect(player.attack).to be 30
    expect(player.defense).to be 10
  end

  it "should have all negative potions reversed" do
    player = Elf.new
    old_hp = player.hitpoints
    potion = Potion.new(-10, :@hitpoints)
    player.quaff potion
    new_hp = player.hitpoints
    expect(new_hp).to eq(old_hp + potion.magnitude.abs)
  end

  it "should treat positive potions normally" do
    player = Elf.new
    old_atk = player.attack
    potion = Potion.new(10, :@attack)
    player.quaff potion
    new_atk = player.attack
    expect(new_atk).to eq(old_atk + potion.magnitude)
  end
end

describe 'Orc Race' do
  it "should have an appropriately attr'd orc character." do
    player = Orc.new
    expect(player.hitpoints).to be 180
    expect(player.attack).to be 30
    expect(player.defense).to be 25
  end

  it 'should get half as much gold' do
    player = Orc.new
    player.gain_gold 20
    expect(player.gold).to be 10
  end
end
