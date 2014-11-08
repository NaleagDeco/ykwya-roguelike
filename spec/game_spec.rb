require 'frappuccino'

describe 'Game' do
  it 'should end when player health is <= 0' do
    player = YKWYA::Player::Player.new(0, 0, 0)
    game = YKWYA::Game.new(player, [[]], Frappuccino::Stream.new)
    expect(game.is_over?).to be(true)
  end
end
