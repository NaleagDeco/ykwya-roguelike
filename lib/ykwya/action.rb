require 'singleton'

module YKWYA
  class Action
    include Singleton

    def move_left!
      emit :move_left
      emit :tick
    end

    def move_right!
      emit :move_right
      emit :tick
    end

    def move_up!
      emit :move_up
      emit :tick
    end

    def move_down!
      emit :move_down
      emit :tick
    end

    def move_upright!
      emit :move_upright
      emit :tick
    end

    def move_upleft!
      emit :move_upleft
      emit :tick
    end

    def move_downright!
      emit :move_downright
      emit :tick
    end

    def move_downleft!
      emit :move_downleft
      emit :tick
    end

    def wait!
      emit :tick
    end
  end
end
