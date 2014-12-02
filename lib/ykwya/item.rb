require_relative 'game-piece'

##
# A helper method to convert StudlyCaps to underscore-delimited format
class String
  # ruby mutation methods have the expectation to return self if a mutation occurred, nil otherwise. (see http://www.ruby-doc.org/core-1.9.3/String.html#method-i-gsub-21)
  def to_underscore!
    g = gsub!(/(.)([A-Z])/,'\1_\2'); d = downcase!
    g || d
  end

  def to_underscore
    dup.tap { |s| s.to_underscore! }
  end
end

module YKWYA
  class Potion
    include GamePieceMixin

    def self.potion_seed
      [
       ['RestoreHealth', 10, :@hitpoints],
       ['PoisonHealth', -10, :@hitpoints],
       ['BoostAttack', 5, :@attack],
       ['WoundAttack', -5, :@attack],
       ['BoostDefense', 5, :@defense],
       ['WoundDefense', -5, :@defense]
      ]
    end

    ##
    # What attribute is this potion supposed to adjust?
    # Because this is awful metaprogramming, this string has to
    # be in the form of a player attribute.
    #
    # ---
    # FIXME: This is probably an awful use of metaprogramming.
    # +++
    attr_reader :attribute
    ##
    # How many numeric points (can be positive or negative)
    # does this potion affect the relevant player attribute?
    attr_reader :magnitude

    def initialize(magnitude, attribute)
      @magnitude = magnitude
      @attribute = attribute
    end
  end

  class Gold
    include GamePieceMixin

    class << self
      attr_reader :amount
    end
  end

  class NormalPile < Gold
    @amount = 1
  end

  class DragonPile < Gold
    @amount = 8
  end

  class MerchantPile < Gold
    @amount = 4
  end

  class SmallPile < Gold
    @amount = 2
  end

  module PotionFactory
    class << self
      Potion.potion_seed.each do |potion|
        self.send(:define_method, potion[0].to_underscore) do
          Potion.new(potion[1], potion[2])
        end
      end
    end
  end

end
