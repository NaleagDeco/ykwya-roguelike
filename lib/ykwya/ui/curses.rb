require 'curses'

include Curses

module YKWYA::UI
  class CursesUI
    def initialize
      #@renderer = CursesRenderer.new
    end

    def run!
      noecho

      @screen = Window.new(30, 79, 0, 0)
      @main = @screen.subwin(25, 79, 0, 0)
      @main.box('|', '-')
      @status = @screen.subwin(5, 79, 25, 0)

      @game = YKWYA::Game.new YKWYA::Human.new

      loop do
        render!
        action = @screen.getch
        if action == 'q'
          @status.clear
          @status.setpos(@status.begy, @status.begx)
          @status << "Do you really want to quit? (Y/N)"
          break if (@status.getch == 'y')
        end
      end

      close_screen
    end

    def render!

    end
  end
end
