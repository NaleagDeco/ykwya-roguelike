include YKWYA

describe 'Player' do
  def ensure_moves_n_spaces_right(map, attempted, expected)
    game = Game.new(Human.new, map)
    old_coords = game.player_coords
    attempted.times do
      game.player_right!
    end
    new_coords = game.player_coords
    expect(new_coords[1] - old_coords[1]).to eq(expected)
  end

  it 'can move from one empty space to another empty space' do
    map = [[VerticalWall.new, HorizontalWall.new, HorizontalWall.new,
            VerticalWall.new],
           [VerticalWall.new, Empty.new, Empty.new, VerticalWall.new],
           [VerticalWall.new, HorizontalWall.new, HorizontalWall.new,
            VerticalWall.new]]
    ensure_moves_n_spaces_right(map, 1, 1)
  end

  it 'cannot move from empty space into a wall' do
    map = [[VerticalWall.new, HorizontalWall.new, HorizontalWall.new,
            VerticalWall.new],
           [VerticalWall.new, Empty.new, HorizontalWall.new, VerticalWall.new],
           [VerticalWall.new, HorizontalWall.new, HorizontalWall.new,
            VerticalWall.new]]
    ensure_moves_n_spaces_right(map, 1, 0)
  end

  it 'cannot move from a passage into inaccessible space' do
    map = [[Empty.new, Passage.new, Inaccessible.new, Inaccessible.new]]
    ensure_moves_n_spaces_right(map, 2, 1)
  end

  it 'cannot move from empty space into a closed door' do
    map = [[Empty.new, Door.new(false), Passage.new, VerticalWall.new]]
    ensure_moves_n_spaces_right(map, 1, 0)
  end

  it 'can move from empty space into an open door' do
    map = [[VerticalWall.new, Empty.new, Door.new(true), Passage.new]]
    ensure_moves_n_spaces_right(map, 1, 1)
  end

  it 'can move from an open door into a passage' do
    map = [[Empty.new, Door.new(true), Passage.new, Inaccessible.new]]
    ensure_moves_n_spaces_right(map, 2, 2)
  end

  it 'can move from an open door into empty space' do
    map = [[Empty.new, Door.new(true), Empty.new, VerticalWall.new]]
    ensure_moves_n_spaces_right(map, 1, 1)
  end

  it 'cannot move from a passage into a closed door' do
    map = [[Empty.new, Passage.new, Door.new(false), VerticalWall.new]]
    ensure_moves_n_spaces_right(map, 2, 1)
  end
end
