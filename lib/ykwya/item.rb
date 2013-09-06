require 'ykwya/game-piece'

module YKWYA
  class Potion
    include GamePieceMixin

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
  end

end
