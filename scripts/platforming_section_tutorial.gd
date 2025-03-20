## This script and scene serves as an _EXAMPLE_. Think env.example. 
## It strives to automate nearly everything about hooking up a new section to the main game.
## It should be duplicated, renamed, and then dropped into the main game scene with the MainGame.
## This script should not need to be edited, only the scene.
## To create a section, simply drag and drop GrowingPlatform3Ds into the scene and use their parameters in the Inspector.
## Then assign the player to MainGame and Hook up the player_entered_section signal

## The scene is also designed to be edited and tested on it's own without needing the MainGame for quicker testing.
## Simply run it as the main scene.
## DeathPlanes in this scene are for testing purposes only. All main game DeathPlanes should be placed in MainGame.
class_name PlatformingSectionTutorial extends PlatformingSection
