require 'spec_helper'


describe 'Game' do
  it "should end when the player's health is <= 0" do
    player = YKWYA::Player::Player.new(0,0,0)
    game = YKWYA::Game.new player
    expect(game.is_over?).to be(true)
  end
end
