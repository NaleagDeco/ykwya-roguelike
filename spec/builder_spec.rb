describe 'Potion Builders' do
  context 'NoPotion Builder' do
    it 'should produce no potions' do
      expect(YKWYA::Builders::NoPotions.new.build_potions).to eq([])
    end
  end

  context 'Uniformly distributed potion builder' do
    it 'should produce as many potions as provided in constructor' do
      NUM_POTIONS = 10
      expect(YKWYA::Builders::UniformlyRandomPotions
              .new(NUM_POTIONS)
              .build_potions.size)
        .to eq(NUM_POTIONS)
    end
  end
end

describe 'Monster Builders' do
  context 'Supplied distribution monster builder' do
    it 'should produce as many potions as provided in constructor' do
      NUM_MONSTERS = 20
      expect(YKWYA::Builders::PresuppliedDistributionOfMonsters
              .new(NUM_MONSTERS, { YKWYA::Vampire => 1 })
              .build_monsters.size)
        .to eq(NUM_MONSTERS)
    end
  end
end
