require 'frappuccino'

include YKWYA

describe 'Player' do
  def ensure_moves_n_spaces_right(builder, attempted, expected)
    dungeon = Dungeon.new builder
    game = Game.new(Human.new, dungeon, Frappuccino::Stream.new)
    old_coords = game.player_coords
    attempted.times do
      game.player_right!
    end
    new_coords = game.player_coords
    expect(new_coords[1] - old_coords[1]).to eq(expected)
  end

  it 'can move from one empty space to another empty space' do
    builder = YKWYA::Builders::DungeonFromHash.new(
      [0, 0] => VerticalWall.new,
      [0, 1] => Empty.new,
      [0, 2] => Empty.new,
      [0, 3] => VerticalWall.new)
    ensure_moves_n_spaces_right(builder, 1, 1)
  end

  it 'cannot move from empty space into a wall' do
    builder = YKWYA::Builders::DungeonFromHash.new(
      [0, 0] => VerticalWall.new,
      [0, 1] => Empty.new,
      [0, 2] => HorizontalWall.new,
      [0, 3] => VerticalWall.new)
    ensure_moves_n_spaces_right(builder, 1, 0)
  end

  it 'cannot move from a passage into inaccessible space' do
    builder = YKWYA::Builders::DungeonFromHash.new(
      [0, 0] => Empty.new,
      [0, 1] => Passage.new)
    ensure_moves_n_spaces_right(builder, 2, 1)
  end

  it 'cannot move from empty space into a closed door' do
    builder = YKWYA::Builders::DungeonFromHash.new(
      [0, 0] => Empty.new,
      [0, 1] => Door.new(false),
      [0, 2] => Passage.new,
      [0, 3] => VerticalWall)
    ensure_moves_n_spaces_right(builder, 1, 0)
  end

  it 'can move from empty space into an open door' do
    builder = YKWYA::Builders::DungeonFromHash.new(
      [0, 0] => VerticalWall.new,
      [0, 1] => Empty.new,
      [0, 2] => Door.new(true),
      [0, 3] => Passage.new)
    ensure_moves_n_spaces_right(builder, 1, 1)
  end

  it 'can move from an open door into a passage' do
    builder = YKWYA::Builders::DungeonFromHash.new(
      [0, 0] => Empty.new,
      [0, 1] => Door.new(true),
      [0, 2] => Passage.new)
    ensure_moves_n_spaces_right(builder, 2, 2)
  end

  it 'can move from an open door into empty space' do
    builder = YKWYA::Builders::DungeonFromHash.new(
      [0, 0] => Empty.new,
      [0, 1] => Door.new(true),
      [0, 2] => Empty.new,
      [0, 3] => VerticalWall.new)
    ensure_moves_n_spaces_right(builder, 1, 1)
  end

  it 'cannot move from a passage into a closed door' do
    builder = YKWYA::Builders::DungeonFromHash.new(
      [0, 0] => Empty.new,
      [0, 1] => Passage.new,
      [0, 2] => Door.new(false),
      [0, 3] => VerticalWall.new)
    ensure_moves_n_spaces_right(builder, 2, 1)
  end
end
