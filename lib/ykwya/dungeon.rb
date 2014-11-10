module YKWYA
  class Level
    ROWS = 23
    COLS = 77

    attr_reader :map

    def initialize
      filename = File.expand_path('../../templates/map.txt',
                                  File.dirname(__FILE__))
      @map = self.class.load_from_file File.open(filename)
    end

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
