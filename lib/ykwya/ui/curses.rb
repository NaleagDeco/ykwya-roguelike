require_relative 'text-renderer'
require_relative '../game'
require_relative '../player'

require 'curses'

include Curses

module YKWYA::UI
  class CursesUI
    COLS = 79
    OFFSETX = 1
    OFFSETY = 1

    def initialize
      @renderer = TextRenderer.new
      @game = YKWYA::Game.new YKWYA::Human.new
    end

    def run!
      noecho

      @screen = Window.new(30, COLS, 0, 0)
      @main = @screen.subwin(25, COLS, 0, 0)
      @main.box('|', '-')
      @status = @screen.subwin(5, COLS, 25, 0)

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
      render_status!
      @main.refresh
    end

    def render_status!
      line1_left = "Race: #{@game.player.race} Gold: #{@game.player.gold}"
      line1_right = "Floor 1"
      line2 = "HP: #{@game.player.hitpoints} \n"
      line3 = "Atk: #{@game.player.attack} \n"
      line4 = "Def: #{@game.player.defense} \n"
      line5 = "Action:\n"
      @status.clear
      @status << line1_left + " " * (COLS - line1_left.size - line1_right.size) + line1_right
      @status << line2
      @status << line3
      @status << line4
      @status << line5
      @status.refresh
    end
  end
end
