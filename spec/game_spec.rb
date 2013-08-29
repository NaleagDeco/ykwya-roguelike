require 'spec_helper'

require 'ykwya/game'
require 'ykwya/player'


describe 'Game' do
  it "should end when the player's health is <= 0" do
    player = YKWYA::Player::Player.new(0,0,0)
    game = YKWYA::Game.new player
    game.is_over?.should be_true
  end
end
