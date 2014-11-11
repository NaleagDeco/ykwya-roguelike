require_relative '../tile'

module YKWYA
  module Builders
    class DungeonFromIO
      def initialize(level_io)
        @level_io = level_io
      end

      def build_dungeon
        map = Hash.new(YKWYA::Inaccessible.new)

        row = -1
        @level_io.each_line do |line|
          row += 1
          col = -1
          line.each_char do |char|
            col += 1
            map[[row, col]] = glyph_to_object(char)
          end
        end

        @level_io.seek(0)
        map
      end

      private

      def glyph_to_object(char)
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
          Door.new(false)
        when '*'
          Door.new(true)
        else
          Inaccessible.new
        end
      end
    end

    class DungeonFromHash
      def initialize(hash)
        @seed_hash = hash.clone
        @seed_hash.default = Inaccessible.new
      end

      def build_dungeon
        @seed_hash.clone
      end
    end
  end
end
