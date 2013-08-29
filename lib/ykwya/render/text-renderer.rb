module YKWYA
  module Render
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
                  # Items
                  'Potion' => 'P',
                  'Gold' => 'G',
                 }
      
      def render object
        # This is a naive solution, we should spend some
        # time investigating if there is a better way of
        # doing this.
        # TODO Can we do something more efficient than an
        # inspection + lookup?
        @@glyphs[object.class.name.split('::').last]
      end
    end   
  end
end
