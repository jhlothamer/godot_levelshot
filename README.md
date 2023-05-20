# Godot Levelshot For Godot 3.x
This plugin allows you to take a screenshot of your entire 2D game level.

## How Does It Work (High Level)

The plugin consists of a main scene UI (see How to Use below) and a Levelshot Capture scene.  The main scene UI is for managing data for Levelshot, allowing you to add levels, set max image size, and other options.

The real magic happens in the Levelshot Capture scene.  This scene is launched by the Levelshot plugin (just like when you "play" one of your level scenes).  The Levelshot Capture scene then loads game levels one at a time, making some in-memory modification, and finally taking a screenshot of the entire game level.

Want to know the gory details?  Please see the Gory Details section below.

### Not all Game Levels Will Work with Levelshot

Game levels that require some sort of setup to occur before they can be loaded and executed will not work with the current version of Levelshot.  Such setup might involve assumptions of going through a menu screen to get to the game level, which sets up some data in some Singleton, or loads some resources, etc.

However, if you can launch your game level in debug mode right from the Godot editor (via Play Scene button), then everything should work.

If this limitation is too cumbersome to work around, please let me know.  With feedback and experience, we can probably find a way around this issue together.

### You can Still Use SceneTree.root and SceneTree.current_scene

If, for some reason, you have code that gets at the current scene by getting the last child node of the SceneTree.root node (or /root), this is still supported.

If you make use of the SceenTree.current_scene property to get at the current scene, this too is still supported.

If you are curious as to how, please see the Gory Details section below.

## Installation

 1. Download or clone this repository
 2. Copy the levelshot folder from the project/addons folder into your project
 3. Enable the Levelshot plugin on the Plugins tab on the Project Settings dialog
 4. Enjoy


## Godot Asset Library?

This plugin will be added to the Godot asset library once it's been tested a bit by the community and maybe some more enhancements have been made.  At that time the installation instructions will be updated.

## Godot 4 Version?

This plugin will be ported to Godot 4 at some point when the plugin has been whipped into a useful form and is not likely to be changed very much.


## Gotchas

ParallaxBackground nodes may throw off the level boundary calculation, or, if not mirroring, not completely fill the background of the level image.  If this happens, you'll need to extend the assets in that background, or switch to using a mirrored background.


## How to use

This is the main scene for the Levelshot plugin.  Most labels and controls have tooltips on them.

<p align="center">
<img src="readme_images/levelshot_main_screen.png" />
</p>

To add a level scene to Levelshot, click the "+" button next to the Levels list label.

### Settings
Levelshot currently supports the following settings.

#### General Settings

* Save Folder - The folder levelshot images will be saved in.  This folder will be created under user://
* Capture Current Level - initiates the Levelshot Capture process for the currently selected level.
* Caputre All Levels - initiates the Levelshot Capture process for all levels.

#### Level Settings

* Max Image Size - The maximum size of the levelshot image.  The resulting image will most likely not be this size as the aspect ratio of the level boundary will be kept.
* Level Boundary - How the level boundary is determined
* * Calculated - The level boundary is calculated out of all the visible nodes in the game level.
* * Use LevelshotReferenceRect - The level boundary is set by placing a LevelshotReferenceRect inside the game level.  You can have multiple LevelshotReferenceRect nodes, which will result in multiple levelshot images.
* Excluded Node Groups - a comma separated list of node groups to exclude.  These nodes are made invisible.
* Include Canvas Layers - CanvasLayer nodes are often used for HUDs and other overlays.  If you do want them in the levelshot, check this option.
* Disable Levelshot for this level - prevents levelshot captures while preserving settings for the level.
* Remove Level - remove the level from Levelshot.  (The level scene itself is NOT touched.)


## Gory Details

The Levelshot Capture scene processes each game level with the following steps.

1. The game level scene is loaded
    * using the GDScript load() function
2. The level scene is instanced
3. We wait for the next idle_frame
    * via yield(get_tree(), "idle_frame") (won't repeat this again for other idle_frame steps)
    * if this isn't done, a "node busy" error can be raised on the next step
4. The level instance is manually added to the root node (SceneTree.root or /root)
    * SceneTree.root.add_child(level_instance)
5. SceneTree.current_scene is set to the level instance
3. We wait for the next idle_frame
    * this allows things to process for a bit - game level code initialization, setup, etc.
6. Level boundaries are processed
    * This is either calculated or specified by LevelshotReferenceRect nodes (see Level Settings for more on differences.)
    * During this process nodes are modified or freed
    * * All nodes have their pause mode set to PAUSE_MODE_STOP  (node.pause_mode = Node.PAUSE_MODE_STOP)
    * * Nodes in an excluded node group are made invisible (visible = false)
    * * CanvasLayer nodes are made invisible (visible = false) unless Level Setting says otherwise (see Level Settings)
    * * Camera2D nodes are freed - extra cameras in the level can interfere with levelshot capture (There can only be one!)
7. We wait for the next idle_frame
    * while processing the level boundary some changes may have been done - we need to let the engine catch up
8. The scene tree is paused
    * via get_tree().paused = true
    * with the game level code paused, we can move the level scene node
9. The level instance is moved from the root node to a place in the Levelshot Capture scene tree, to be under a Viewport we can control
10. We wait for the next idle_frame
    * This allows the engine to catchup to the pause and move
11. A new Camera2D is created, made current and added to the Levelshot Capture Viewport node
13. For each level boundary
    1. Calculate how much the level boundary must be shrunk to fit into the max image size
    2. Set the Viewport and ViewportContainer sizes to this calulated size
    3. Position the camera in the middle of the level
    4. Set the camera zoom so that the entire level is in view
    5. Wait for the next idle_frame to let the engine catch up
    6. Obtain the image from the Viewport node and save it to the save folder




































