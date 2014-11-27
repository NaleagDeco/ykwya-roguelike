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
      @input_stream = Frappuccino::Stream.new(YKWYA::Action.instance)

      Pry.config.hooks.add_hook(:before_session, :disable_curses) do
        close_screen
      end

      Pry.config.hooks.add_hook(:after_session, :enable_curses) do
        doupdate
      end
    end

    def run!
      noecho
      curs_set 0

      @screen = Window.new(30, COLS, 0, 0)
      @main = @screen.subwin(25, COLS, 0, 0)
      @main.box('|', '-')
      @status = @screen.subwin(5, COLS, 25, 0)

      @player = YKWYA::Human.new
      @game = YKWYA::Game.new(@player, @input_stream)

      @message = @game.streams[:message].on_value do |event|
        string = case event.type
                 when :attack
                   result = event.data
                   attacker = @renderer.name result[0]
                   defender = @renderer.name result[1]
                   if result[2] == :missed
                     "#{attacker} missed when attacking #{defender}!"
                   elsif result[2] == :defeated
                     "#{attacker} defeated #{defender}!"
                   else
                     "#{attacker} attacked #{defender} for #{result[2]} damage!"
                   end
                 when :playerdead
                   'You are dead!'
                 end
        action_message! string
      end

      loop do
        render!
        input_char = @screen.getch
        if input_char == 'q'
          @status.clear
          @status.setpos(@status.begy, @status.begx)
          @status << "Do you really want to quit? (Y/N)"
          break if @status.getch == 'y'
        end
        execute_command! input_char unless @player.dead?
      end
      close_screen
    end

    private

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
      when 'w'
        YKWYA::Action.instance.wait!
      end
    end

    def render!
      render_main_screen!
      render_status!
    end

    def render_main_screen!
      @main.clear
      draw_map!
      draw! @game.hoards
      draw! @game.potions
      draw_stairway!
      draw! @game.monsters
      draw_player!
      @main.refresh
    end

    def render_status!
      line1_left = "Race: #{@player.race} Gold: #{@player.gold}"
      line1_right = "Floor 1"
      line2 = "HP: #{@player.hitpoints}\n"
      line3 = "Atk: #{@player.attack}\n"
      line4 = "Def: #{@player.defense}\n"
      line5 = "Action: "

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
      @game.map.each_pair do |coords, tile|
        @main.setpos(coords[0] + OFFSETY, coords[1] + OFFSETX)
        @main.addch(tile.render_by @renderer)
      end
    end

    def draw! list
      list.each do |coords|
        @main.setpos(coords[0][0] + OFFSETY, coords[0][1] + OFFSETX)
        @main.addch(coords[1].render_by @renderer)
      end
    end

    def draw_stairway!
      @main.setpos(*(map_to_curses @game.stairway_coords))
      @main.addch('\\')
    end

    def draw_player!
      @main.setpos(*(map_to_curses @game.player_coords))
      @main.addch(@player.render_by(@renderer))
    end

    def action_message! string
      offset = [4, 'Action: '.length]

      @status.setpos(*offset)
      @status << string
      @status.refresh
      sleep 0.25
      @status << ' --Press Any Key --'
      @status.refresh
      @status.getch
      @status.setpos(*offset)
      @status.clrtoeol
      @status.refresh
    end

    def map_to_curses(coords)
      coords.map { |coord| coord + 1 }
    end
  end
end
