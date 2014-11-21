module YKWYA
  ##
  # Indicates that this is object that will render in some way to the screen
  # as a game piece.
  module GamePieceMixin
    def render_by(renderer)
      renderer.render self
    end

    def ==(other)
      self.class.name == other.class.name
    end
  end

  module Fighter
    def fight(enemy)
      enemy.fought_by self
    end
  end

  module Fightable
    ##
    # Callback to indicate that this monster was attacked by a player
    def fought_by(belligerent)
      damage = ((100.0 / (100.0 + defense)) * belligerent.attack).ceil

      if rand(2) == 1
        @hitpoints -=  damage
        emit "Player was attacked by #{belligerent} for #{damage} damage!"
      else
        emit "#{belligerent} misses!"
      end
    end
  end
end
