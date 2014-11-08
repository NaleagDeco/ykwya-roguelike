module YKWYA
  class Dungeon
    def initialize(seed_file)
      @seed_level = Level.load_from_file seed_file
      @floors = []
    end

    def switch_level(level)
      if floors[level].nil?
        floors[level] = @seed_level.clone{}
      end
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

    private

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
