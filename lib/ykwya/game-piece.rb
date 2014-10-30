module YKWYA

  ##
  # Indicates that this is object that will render in some way to the screen
  # as a game piece.
  module GamePieceMixin
    def render_by(renderer)
      renderer.render self
    end

    def ==(y)
      self.class.name == y.class.name
    end
  end

  class VerticalWall
    include GamePieceMixin
  end

  class HorizontalWall
    include GamePieceMixin
  end

  class Passage
    include GamePieceMixin
  end

  class Empty
    include GamePieceMixin
  end

  class Door
    include GamePieceMixin
  end

  class Inaccessible
    include GamePieceMixin
  end
end
