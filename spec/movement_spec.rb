require 'frappuccino'

include YKWYA

describe 'Player movement' do
  def ensure_moves_n_spaces_right(builder, attempted, expected)
    game = Game.new(Human.new, Frappuccino::Stream.new, builder,
                    YKWYA::Builders::NoPotions.new,
                    YKWYA::Builders::NoMonsters.new,
                    YKWYA::Builders::NoGold.new)
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

  it 'can move from empty space into an open door' do
    builder = YKWYA::Builders::DungeonFromHash.new(
      [0, 0] => VerticalWall.new,
      [0, 1] => Empty.new,
      [0, 2] => Door.new,
      [0, 3] => Passage.new)
    ensure_moves_n_spaces_right(builder, 1, 1)
  end

  it 'can move from an open door into a passage' do
    builder = YKWYA::Builders::DungeonFromHash.new(
      [0, 0] => Empty.new,
      [0, 1] => Door.new,
      [0, 2] => Passage.new)
    ensure_moves_n_spaces_right(builder, 2, 2)
  end

  it 'can move from an open door into empty space' do
    builder = YKWYA::Builders::DungeonFromHash.new(
      [0, 0] => Empty.new,
      [0, 1] => Door.new,
      [0, 2] => Empty.new,
      [0, 3] => VerticalWall.new)
    ensure_moves_n_spaces_right(builder, 1, 1)
  end
end

describe 'player pickup' do
  it 'potion' do
    dungeon_builder = Builders::DungeonFromHash.new(
      [0, 0] => Empty.new,
      [0, 1] => Empty.new)

    player = Human.new
    game = Game.new(player, Frappuccino::Stream.new,
                    dungeon_builder, Builders::NoPotions.new,
                    Builders::NoMonsters.new, Builders::NoGold.new)
    game.instance_eval do
      @potions = [[[0, 1], PotionFactory.boost_attack]]
    end
    old_attack = player.attack
    game.player_right!
    expect(player.attack).to be > old_attack
    expect(game.potions.size).to eq(0)
  end

  it 'gold' do
    dungeon_builder = Builders::DungeonFromHash.new(
      [0, 0] => Empty.new,
      [0, 1] => Empty.new)

    player = Human.new
    game = Game.new(player, Frappuccino::Stream.new,
                    dungeon_builder, Builders::NoPotions.new,
                    Builders::NoMonsters.new, Builders::NoGold.new)
    game.instance_eval do
      @hoards = [[[0, 1], NormalPile.new]]
    end
    old_gold = player.gold
    game.player_right!
    expect(player.gold).to be > old_gold
    expect(game.hoards.size).to eq(0)
  end
end
