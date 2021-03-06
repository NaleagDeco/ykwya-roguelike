require_relative '../player'

module YKWYA
  ##
  # Renderers for the game
  module UI
    ##
    # Render the game in a traditional roguelike way.
    class TextRenderer
      @@glyphs = {
                  # Monsters
                  'Merchant' => 'M',
                  'Vampire' => 'V',
                  'Dragon' => 'D',
                  'Phoenix' => 'X',
                  'Goblin' => 'N',
                  'Troll' => 'T',
                  'Werewolf' => 'W',
                  # Players
                  'Player' => '@',
                  'Human' => '@',
                  'Orc' => '@',
                  'Dwarf' => '@',
                  'Elf' => '@',
                  # Items
                  'Potion' => 'P',
                  'Gold' => 'G',
                  'NormalPile' => 'G',
                  'DragonPile' => 'G',
                  'SmallPile' => 'G',
                  # Scenery
                  'HorizontalWall' => '-',
                  'VerticalWall' => '|',
                  'Empty' => '.',
                  'Door' => '+',
                  'Passage' => '#',
                  'Inaccessible' => ' '
                 }

      ##
      # Render the game object.
      def render(object)
        # This is a naive solution, we should spend some
        # time investigating if there is a better way of
        # doing this.b
        # TODO Can we do something more efficient than an
        # inspection + lookup?
        @@glyphs[object.class.name.split('::').last]
      end

      def name(object)
        if object.is_a? YKWYA::Player
          "Player"
        else
          object.class.name.split('::').last
        end
      end
    end
  end
end
