require 'spec_helper'

include YKWYA


describe "Text-based UI" do
  before(:all) do
    @renderer = Render::TextRenderer.new
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
  glyph_represents 'G', Gold.new

  # Player
  glyph_represents '@', Player.new(0,0,0)
end
