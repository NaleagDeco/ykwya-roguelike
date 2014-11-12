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
