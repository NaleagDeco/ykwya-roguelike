require_relative 'text-renderer'
require_relative '../game'

require 'curses'

include Curses

module YKWYA::UI
  class CursesUI
    OFFSETX = 1
    OFFSETY = 1

    def initialize
      @renderer = TextRenderer.new
    end

    def run!
      noecho

      @screen = Window.new(30, 79, 0, 0)
      @main = @screen.subwin(25, 79, 0, 0)
      @main.box('|', '-')
      @status = @screen.subwin(5, 79, 25, 0)

      file = File.open(
        File.expand_path('../../../templates/map.txt',
                         File.dirname(__FILE__)))
      @map = YKWYA::Level.load_from_file(file)

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
      @map.map.with_index(offset=OFFSETY) do |row, i|
        row.map.with_index(offset=OFFSETX) do |col, j|
          @main.setpos(i, j)
          @main.addch(col.render_by @renderer)
        end
      end
      @main.refresh
    end
  end
end
