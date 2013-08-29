module YKWYA
  module GamePieceMixin
    def render_by renderer
      renderer.render self
    end
  end
end
