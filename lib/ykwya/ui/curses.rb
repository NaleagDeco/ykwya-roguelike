require_relative 'text-renderer'
require_relative '../game'
require_relative '../player'
require_relative '../action'
require_relative '../dungeon'

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

      @player = YKWYA::Human.new
      @game = YKWYA::Game.new(@player, YKWYA::Dungeon.new, @input_stream)

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
        YKWYA::Action.instance.move_left!
      when 'j'
        YKWYA::Action.instance.move_down!
      when 'k'
        YKWYA::Action.instance.move_up!
      when 'l'
        YKWYA::Action.instance.move_right!
      when 'y'
        YKWYA::Action.instance.move_upleft!
      when 'u'
        YKWYA::Action.instance.move_upright!
      when 'b'
        YKWYA::Action.instance.move_downleft!
      when 'n'
        YKWYA::Action.instance.move_downright!
      end
    end

    def render!
      render_main_screen!
      render_status!
    end

    def render_main_screen!
      @main.clear
      draw_map!
      draw_enemies!
      draw_gold!
      draw_potions!
      draw_stairway!
      draw_player!
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
      @status << line1_left +
        ' ' * (COLS - line1_left.size - line1_right.size) +
        line1_right
      @status << line2
      @status << line3
      @status << line4
      @status << line5
      @status.refresh
    end

    def draw_map!
      @game.dungeon.map.each_pair do |coords, tile|
        @main.setpos(coords[0] + OFFSETY, coords[1] + OFFSETX)
        @main.addch(tile.render_by @renderer)
      end
    end

    def draw_enemies!
      @game.dungeon.monsters.each do |coords|
        @main.setpos(coords[0] + OFFSETY, coords[1] + OFFSETX)
        @main.addch(coords[2].render_by @renderer)
      end
    end

    def draw_gold!
      @game.dungeon.hoards.each do |coords|
        @main.setpos(coords[0] + OFFSETY, coords[1] + OFFSETX)
        @main.addch(coords[2].render_by @renderer)
      end
    end

    def draw_stairway!
    end

    def draw_player!
      @main.setpos(*(map_to_curses @game.player_coords))
      @main.addch(@player.render_by(@renderer))
    end

    def draw_potions!
      @game.dungeon.potions.each do |coords|
        @main.setpos(coords[0] + OFFSETY, coords[1] + OFFSETX)
        @main.addch(coords[2].render_by @renderer)
      end
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
