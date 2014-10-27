Feature: Basic functionaltiy
  As a user
  I should be able to do the simplest things when it comes to playing this game

  Scenario: Quitting the game
    Given I run `ykwya` interactively
    When I type "q"
    Then the exit status should be 0
