module YKWYA

  ##
  # Indicates that this is object that will render in some way to the screen
  # as a game piece.
  module GamePieceMixin
    def render_by renderer
      renderer.render self
    end
  end
end
