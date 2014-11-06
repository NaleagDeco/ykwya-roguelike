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
    end

    def is_over?
      @player.hitpoints <= 0
    end

    def player_coords
      @player_coords.clone
    end

    def player_left!
      new_loc = @map[@player_coords[0]][@player_coords[1] - 1]
      @player_coords[1] -= 1 unless new_loc.inaccessible?
    end

    def player_right!
      new_loc = @map[@player_coords[0]][@player_coords[1] + 1]
      @player_coords[1] += 1 unless new_loc.inaccessible?
    end

    def player_up!
      new_loc = @map[@player_coords[0] - 1][@player_coords[1]]
      @player_coords[0] -= 1 unless new_loc.inaccessible?
    end

    def player_down!
      new_loc = @map[@player_coords[0] + 1][@player_coords[1]]
      @player_coords[0] += 1 unless new_loc.inaccessible?
    end

    private

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
