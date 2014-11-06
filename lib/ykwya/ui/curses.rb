require_relative 'text-renderer'
require_relative '../game'
require_relative '../player'
require_relative '../action'

require 'curses'
require 'frappuccino'

include Curses

module YKWYA::UI
  class CursesUI
    COLS = 79
    OFFSETX = 1
    OFFSETY = 1

    def initialize
      @renderer = TextRenderer.new
      @input_stream = Frappuccino::Stream.new(YKWYA::Action.instance)
    end

    def run!
      noecho
      curs_set 0

      @screen = Window.new(30, COLS, 0, 0)
      @main = @screen.subwin(25, COLS, 0, 0)
      @main.box('|', '-')
      @status = @screen.subwin(5, COLS, 25, 0)

      file = File.open(
        File.expand_path('../../../templates/map.txt',
                         File.dirname(__FILE__)))
      @map = YKWYA::Level.load_from_file(file)

      @player = YKWYA::Human.new
      @game = YKWYA::Game.new(@player, @map)

      loop do
        render!
        input_char = @screen.getch
        if input_char == 'q'
          @status.clear
          @status.setpos(@status.begy, @status.begx)
          @status << "Do you really want to quit? (Y/N)"
          break if (@status.getch == 'y')
        end
        execute_command! input_char
      end

      close_screen
    end

    def execute_command!(char)
      case char
      when 'h'
        YKWYA::Action.instance.move_left
      when 'j'
        YKWYA::Action.instance.move_down
      when 'k'
        YKWYA::Action.instance.move_up
      when 'l'
        YKWYA::Action.instance.move_right
      end
    end

    def render!
      @map.map.with_index(offset = OFFSETY) do |row, i|
        row.map.with_index(offset = OFFSETX) do |col, j|
          @main.setpos(i, j)
          @main.addch(col.render_by @renderer)
        end
      end
      draw_player!
      render_status!
      @main.refresh
    end

    def render_status!
      line1_left = "Race: #{@player.race} Gold: #{@player.gold}"
      line1_right = "Floor 1"
      line2 = "HP: #{@player.hitpoints} \n"
      line3 = "Atk: #{@player.attack} \n"
      line4 = "Def: #{@player.defense} \n"
      line5 = "Action:\n"
      @status.clear
      @status << line1_left + ' ' * (COLS - line1_left.size - line1_right.size) + line1_right
      @status << line2
      @status << line3
      @status << line4
      @status << line5
      @status.refresh
    end

    def draw_player!
      @main.setpos(*(map_to_curses @game.player_coords))
      @main.addch(@player.render_by(@renderer))
    end

    private

    def breakpoint
      require 'pry'

      close_screen
      binding.pry
      doupdate
    end

    def map_to_curses(coords)
      coords.map { |coord| coord + 1 }
    end
  end
end
