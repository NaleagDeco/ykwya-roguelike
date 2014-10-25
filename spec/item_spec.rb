require 'spec_helper'

describe 'PotionFactory' do
  def self.has_potion name, magnitude, attribute
    it 'creates #{magnitude} #{attribute} potion with #{name} function.' do
      potion = PotionFactory.send(name.to_underscore)
      expect(potion.magnitude).to be magnitude
      expect(potion.attribute).to be attribute
    end
  end

  has_potion 'RestoreHealth', 10, :@hitpoints
  has_potion 'PoisonHealth', -10, :@hitpoints

  has_potion 'BoostAttack', 5, :@attack
  has_potion 'WoundAttack', -5, :@attack

  has_potion 'BoostDefense', 5, :@defense
  has_potion 'WoundDefense', -5, :@defense
end
