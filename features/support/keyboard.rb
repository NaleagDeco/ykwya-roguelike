module Aruba::Api
  # Provide data to command via stdin char
  #
  # @param [String] input
  #   The input for the command
  def type_character(input)
    return close_input if "" == input
    _write_interactive(input)
  end
end
