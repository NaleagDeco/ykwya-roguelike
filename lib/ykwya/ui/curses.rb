# coding: utf-8
require_relative 'text-renderer'
require_relative '../game'
require_relative '../player'
require_relative '../action'

require 'curses'
require 'frappuccino'
require 'pry'

include Curses

module YKWYA::UI
  class CursesUI
    COLS = 79
    ROWS = 30
    OFFSETX = 1
    OFFSETY = 1

    def initialize
      @renderer = TextRenderer.new
      @input_stream = Frappuccino::Stream.new(YKWYA::UserInput.instance)

      Pry.config.hooks.add_hook(:before_session, :disable_curses) do
        close_screen
      end

      Pry.config.hooks.add_hook(:after_session, :enable_curses) do
        doupdate
      end
    end

    def initialize_screen
      noecho
      curs_set 0

      @screen = Window.new(30, COLS, 0, 0)
      @main = @screen.subwin(25, COLS, 0, 0)
      @main.box('|', '-')
      @status = @screen.subwin(5, COLS, 25, 0)
    end

    def run!
      initialize_screen

      player = YKWYA::Human.new
      initial_state = YKWYA::GameState.create_game(player)
      game_state = @input_stream.scan(initial_state) do |last_state, input|
        YKWYA::GameState.process_input(last_state, input)
      end
      game_state.on_value do |state|
        render! state
      end
      @input_stream.select { |input| input == :quit }.on_value do
        at_exit do
          close_screen
          puts '♥ Thank you for playing ♥'
        end
        exit
      end

      YKWYA::UserInput.instance.start!
      while true
        @screen.refresh
        execute_command! @main.getch
      end
    end

    private

    def execute_command!(char)
      case char
      when 'h'
        YKWYA::UserInput.instance.move_left!
      when 'j'
        YKWYA::UserInput.instance.move_down!
      when 'k'
        YKWYA::UserInput.instance.move_up!
      when 'l'
        YKWYA::UserInput.instance.move_right!
      when 'y'
        YKWYA::UserInput.instance.move_upleft!
      when 'u'
        YKWYA::UserInput.instance.move_upright!
      when 'b'
        YKWYA::UserInput.instance.move_downleft!
      when 'n'
        YKWYA::UserInput.instance.move_downright!
      when 'w'
        YKWYA::UserInput.instance.wait!
      when 'q'
        YKWYA::UserInput.instance.quit!
      end
    end

    def render!(game_state)
      render_main_screen!(game_state)
      render_status!(game_state)
    end

    def render_main_screen!(game_state)
      @main.clear
      draw_map! game_state
      draw! game_state[:gold]
      draw! game_state[:potions]
      draw_stairway! game_state
      draw! game_state[:monsters]
      draw_player! game_state
      @main.refresh
    end

    def render_status!(game_state)
      player = game_state[:player]
      status = game_state[:status]

      line1_left = "Race: #{player.race} Gold: #{player.gold}"
      line1_right = "Floor 1"
      line2 = "HP: #{player.hitpoints}\n"
      line3 = "Atk: #{player.attack}\n"
      line4 = "Def: #{player.defense}\n"
      line5 = "Action: #{status}"

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

    def draw_map!(game_state)
      map = game_state[:terrain]

      map.each_pair do |coords, tile|
        @main.setpos(coords[0] + OFFSETY, coords[1] + OFFSETX)
        @main.addch(tile.render_by @renderer)
      end
    end

    def draw!(list)
      list.each do |coords|
        @main.setpos(coords[0][0] + OFFSETY, coords[0][1] + OFFSETX)
        @main.addch(coords[1].render_by @renderer)
      end
    end

    def draw_stairway!(game_state)
      @main.setpos(*(map_to_curses game_state[:stairway_coords]))
      @main.addch('\\')
    end

    def draw_player!(game_state)
      @main.setpos(*(map_to_curses game_state[:player_coords]))
      @main.attron(A_STANDOUT)
      @main.addch(game_state[:player].render_by(@renderer))
      @main.attroff(A_STANDOUT)
    end

    def map_to_curses(coords)
      coords.map { |coord| coord + 1 }
    end
  end
end
