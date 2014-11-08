require 'singleton'

module YKWYA
  class Action
    include Singleton

    def move_left!
      emit :move_left
    end

    def move_right!
      emit :move_right
    end

    def move_up!
      emit :move_up
    end

    def move_down!
      emit :move_down
    end

    def move_upright!
      emit :move_upright
    end

    def move_upleft!
      emit :move_upleft
    end

    def move_downright!
      emit :move_downright
    end

    def move_downleft!
      emit :move_downleft
    end
  end
end
