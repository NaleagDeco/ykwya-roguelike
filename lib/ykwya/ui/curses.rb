require 'curses'

include Curses

module YKWYA::UI
  class CursesUI
    def run!
      noecho

      @screen = Window.new(30, 79, 0, 0)
      @main = @screen.subwin(25, 79, 0, 0)
      @main.box('|', '-')
      @status = @screen.subwin(5, 79, 25, 0)


      loop do
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
  end
end
