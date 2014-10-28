Feature: Basic functionaltiy
  As a user
  I should be able to do the simplest things when it comes to playing this game

  Scenario: Quitting the game
    Given I run `ykwya` interactively
    When I type the character "q"
    And I type the character "y"
    Then the exit status should be 0

  Scenario: Deciding against quitting the game
    Given I run `ykwya` interactively
    When I type "q"
    And I type "n"
    Then the exit status should not be 0
