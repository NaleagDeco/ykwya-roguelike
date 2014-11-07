require 'frappuccino'

describe 'Game' do
  it 'should end when player health is <= 0' do
    player = YKWYA::Player::Player.new(0, 0, 0)
    game = YKWYA::Game.new(player, [[]], Frappuccino::Stream.new)
    expect(game.is_over?).to be(true)
  end

  it 'should construct a room from a given file' do
    filename = File.expand_path('../templates/map.txt',
                                File.dirname(__FILE__))
    map = YKWYA::Level.load_from_file(File.open(filename))

    expect(map.size).to eq(YKWYA::Level::ROWS)
    map.each do |row|
      expect(row.size).to eq(YKWYA::Level::COLS)
    end

    [[0, 0, YKWYA::Inaccessible.new],
     [1, 1, YKWYA::VerticalWall.new],
     [32, 7, YKWYA::Passage.new],
     [32, 8, YKWYA::Inaccessible.new],
     [38, 6, YKWYA::HorizontalWall.new],
     [48, 9, YKWYA::Empty.new],
     [68, 14, YKWYA::Door.new]].each do |item|
      expect(map[item[1]][item[0]]).to eq(item[2])
    end
  end
end
