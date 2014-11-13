describe 'floor' do
  before(:each) do
    file = File.open File.expand_path('../templates/map.txt',
                                      File.dirname(__FILE__))
    @terrain_builder = YKWYA::Builders::DungeonFromIO.new file
    @potion_builder = YKWYA::Builders::NoPotions.new
    @monster_builder = YKWYA::Builders::NoMonsters.new

    @level = YKWYA::Level.new(@terrain_builder, @potion_builder, @monster_builder)
  end

  it 'should construct a map from a given file' do
    #expect(map.size).to eq(YKWYA::Level::ROWS)
    #map.each do |row|
    #  expect(row.size).to eq(YKWYA::Level::COLS)
    #end

    map = @level.map

    [[0, 0, YKWYA::Inaccessible.new],
     [1, 1, YKWYA::VerticalWall.new],
     [32, 7, YKWYA::Passage.new],
     [32, 8, YKWYA::Inaccessible.new],
     [38, 6, YKWYA::HorizontalWall.new],
     [48, 9, YKWYA::Empty.new],
     [68, 14, YKWYA::Door.new]].each do |item|
      expect(map[[item[1], item[0]]]).to eq(item[2])
    end
  end

  it 'should have as many potions as builder created' do
    expect(@level.potions.size).to eq(@potion_builder.build_potions.size)
  end
end
