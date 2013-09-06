module YKWYA
  class Game
    def initialize player
      @player = player
    end

    def is_over?
      @player.hitpoints <= 0
    end
  end
end
