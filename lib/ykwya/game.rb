require_relative 'tile'

module YKWYA
  class Game
    def initialize(player, map, input_stream)
      @player = player
      @map = map

      @player_coords = find_empty_space

      input_stream
        .select { |event| event == :move_left }
        .on_value { |_| player_left! }
      input_stream
        .select { |event| event == :move_right }
        .on_value { |_| player_right! }
      input_stream
        .select { |event| event == :move_up }
        .on_value { |_| player_up! }
      input_stream
        .select { |event| event == :move_down }
        .on_value { |_| player_down! }
      input_stream
        .select { |event| event == :move_downleft }
        .on_value { |_| player_downleft! }
      input_stream
        .select { |event| event == :move_downright }
        .on_value { |_| player_downright! }
      input_stream
        .select { |event| event == :move_upleft }
        .on_value { |_| player_upleft! }
      input_stream
        .select { |event| event == :move_upright }
        .on_value { |_| player_upright! }
    end

    def is_over?
      @player.hitpoints <= 0
    end

    def player_coords
      @player_coords.clone
    end

    def player_left!
      player_move! [0, -1]
    end

    def player_right!
      player_move! [0, 1]
    end

    def player_up!
      player_move! [-1, 0]
    end

    def player_down!
      player_move! [1, 0]
    end

    def player_upleft!
      player_move! [-1, -1]
    end

    def player_upright!
      player_move! [-1, 1]
    end

    def player_downleft!
      player_move! [1, -1]
    end

    def player_downright!
      player_move! [1, 1]
    end

    private

    def player_move!(offset)
      new_coords = @player_coords.zip(offset).map do |elem|
        elem.reduce(:+)
      end
      new_loc = @map[new_coords[0]][new_coords[1]]

      @player_coords = new_coords unless new_loc.inaccessible?
    end

    def find_empty_space
      result = [nil, nil]
      @map.each_index do |row_index|
        col_index = @map[row_index].find_index do |elem|
          elem.instance_of? Empty
        end
        if col_index
          result = [row_index, col_index]
          break
        end
      end

      result
    end
  end

  class Level
    ROWS = 23
    COLS = 77

    def self.load_from_file(file)
      map = []
      file.each_line do |line|
        map << []
        line.each_char do |char|
          map[-1] << glyph_to_object(char)
        end
        map[-1] += [Inaccessible.new] * (COLS - map.last.size)
      end

      map += ([Inaccessible.new] * COLS) * (ROWS - map.size)
    end

    def self.glyph_to_object(char)
      case char
      when '|'
        VerticalWall.new
      when '-'
        HorizontalWall.new
      when '#'
        Passage.new
      when '.'
        Empty.new
      when '+'
        Door.new
      else
        Inaccessible.new
      end
    end
  end
end
