require 'singleton'

module YKWYA
  class Action
    include Singleton

    def move_left
      emit(:move_left)
    end

    def move_right
      emit(:move_right)
    end

    def move_up
      emit(:move_up)
    end

    def move_down
      emit(:move_down)
    end
  end
end
