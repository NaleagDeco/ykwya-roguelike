require 'spec_helper'

describe 'PotionFactory' do
  def self.potion?(name, magnitude, attribute)
    it 'creates #{magnitude} #{attribute} potion with #{name} function.' do
      potion = PotionFactory.send(name.to_underscore)
      expect(potion.magnitude).to be magnitude
      expect(potion.attribute).to be attribute
    end
  end

  potion? 'RestoreHealth', 10, :@hitpoints
  potion? 'PoisonHealth', -10, :@hitpoints

  potion? 'BoostAttack', 5, :@attack
  potion? 'WoundAttack', -5, :@attack

  potion? 'BoostDefense', 5, :@defense
  potion? 'WoundDefense', -5, :@defense
end
