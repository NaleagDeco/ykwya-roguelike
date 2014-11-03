require_relative 'game-piece'

module YKWYA
  module RoomMixin
    def inaccessible?
      true
    end
  end

  class VerticalWall
    include GamePieceMixin
    include RoomMixin
  end

  class HorizontalWall
    include GamePieceMixin
    include RoomMixin
  end

  class Passage
    include GamePieceMixin
    include RoomMixin

    def inaccessible?
      false
    end
  end

  class Empty
    include GamePieceMixin
    include RoomMixin

    def inaccessible?
      false
    end
  end

  class Door
    include GamePieceMixin
    include RoomMixin

    def initialize(open = true)
      @open = open
    end

    def open?
      @open
    end

    def inaccessible?
      !@open
    end
  end

  class Inaccessible
    include GamePieceMixin
    include RoomMixin
  end
end
