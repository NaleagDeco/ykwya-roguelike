describe 'floor' do
  before(:each) do
    file = File.open File.expand_path('../templates/map.txt',
                                      File.dirname(__FILE__))
    builder = YKWYA::Builders::DungeonFromIO.new file
    @level = YKWYA::Level.new(builder)
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

  it 'should always have ten potions to start' do
    potions = @level.potions

    expect(potions.size).to eq(10)
  end
end
