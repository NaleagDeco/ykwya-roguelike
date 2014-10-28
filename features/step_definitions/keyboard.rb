require 'aruba/api'

World(Aruba::Api)

When(/^I type the character "([^"])"$/) do |input|
  type_character(input)
end
