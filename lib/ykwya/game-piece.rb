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
    ##
    # Returns [attacker, defender, damage/:missed]
    def fight(enemy)
      enemy.fought_by self
    end
  end

  module Fightable
    ##
    # Callback to indicate that this monster was attacked by a player
    #
    # Returns [attacker, defender, :missed]
    def fought_by(belligerent)
      # 50% chance of attack missing
      if rand(2) == 1
        damage = ((100.0 / (100.0 + defense)) * belligerent.attack).ceil
        @hitpoints -= damage
        damage = :defeated if dead?
      else
        damage = :missed
      end

      [belligerent, self, damage]
    end

    ##
    # Am I dead?
    def dead?
      @hitpoints <= 0
    end
  end
end
