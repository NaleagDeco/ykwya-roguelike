require 'curses'

include Curses

module YKWYA::UI
  class CursesUI
    def run!
      @screen = Window.new(30, 79, 0, 0)
      @main = @screen.subwin(25, 79, 0, 0)
      @main.box('|', '-')
      @status = @screen.subwin(5, 79, 25, 0)


      until (@screen.getch) == 'q' do
        # Absolutely nothing
      end
    end
  end
end
