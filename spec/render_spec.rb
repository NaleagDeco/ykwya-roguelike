require 'spec_helper'

include YKWYA

describe "Text-based UI" do
  before(:all) do
    @renderer = UI::TextRenderer.new
  end

  def self.glyph_represents glyph, object
    it("should represent #{object.class.name} with the glyph '#{glyph}'") do
      expect(object.render_by @renderer).to eq glyph
    end
  end

  # Monsters
  glyph_represents 'V', Vampire.new
  glyph_represents 'W', Werewolf.new
  glyph_represents 'N', Goblin.new
  glyph_represents 'M', Merchant.new
  glyph_represents 'D', Dragon.new
  glyph_represents 'X', Phoenix.new
  glyph_represents 'T', Troll.new

  # Items
  glyph_represents 'P', Potion.new(5, :attack)
  glyph_represents 'G', NormalPile.new
  glyph_represents 'G', SmallPile.new
  glyph_represents 'G', DragonPile.new

  # Player
  glyph_represents '@', Player.new(0, 0, 0)
  glyph_represents '@', Human.new
  glyph_represents '@', Orc.new
  glyph_represents '@', Elf.new
  glyph_represents '@', Dwarf.new

  # Scenery
  glyph_represents '+', Door.new
  glyph_represents '-', HorizontalWall.new
  glyph_represents '|', VerticalWall.new
  glyph_represents '.', Empty.new
  glyph_represents '#', Passage.new
  glyph_represents ' ', Inaccessible.new
end
