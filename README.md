# Godot Levelshot For Godot 3.x
This plugin allows you to take a screenshot of your entire 2D game level.

## How Does It Work (High Level)

The plugin consists of a main scene UI (see How to Use below) and a Levelshot Capture scene.  The main scene UI is for managing data for Levelshot, allowing you to add levels, set max image size, and other options.

The real magic happens in the Levelshot Capture scene.  This scene is launched by the Levelshot plugin (just like when you "play" one of your level scenes).  The Levelshot Capture scene then loads game levels one at a time, making some in-memory modification, and finally taking a screenshot of the entire game level.

For those wanting to know more detail, see the How Does It Work (Detail) section.

### Note: Not all Game Levels Will Work with Levelshot

Game levels that require some sort of setup to occur before they can be loaded and executed will not work with the current version of Levelshot.  Such setup might involve assumptions of going through a menu screen to get to the game level, which sets up some data in some Singleton, or loads some resources, etc.

However, if you can launch your game level in debug mode right from the Godot editor (via Play Scene button), then everything should work.

If this limitation is too cumbersome to work around, please let me know.  With feedback and experience, we can probably find a way around this issue together.

### You can Still Use SceneTree.root and SceneTree.current_scene

If, for some reason, you have code that gets at the current scene by getting the last child node of the SceneTree.root node (or /root), this is still supported.

If you make use of the SceenTree.current_scene property to get at the current scene, this too is still supported.

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
* Capture All Levels - initiates the Levelshot Capture process for all levels.

#### Level Settings

##### Image Size

The image size is derived from the level boundary.  This can be calculated with one of the following options:

* Scale - The image size is a scaled version of the level boundary.  This is done by multiplying a Vector2 of the level boundary with the scale fraction.  (level_boundary * 1.0 / scale)
* Max Image Size - The image size is scaled so that it fits within the given max image size while keeping the level boundary aspect ratio.
* Scale by limit to Max Size - As the name implies, first the Scale option is calculated.  If that's bigger than Max Image Size, then the Max Image Size calculation is done.

##### Level Boundary

These options determine how the level boundary is calculated.

* Calculated - The level boundary is calculated by taking all of the rectangles of all visible nodes.
* Use LevelshotReferenceRect - The level boundary is set by placing a LevelshotReferenceRect inside the game level.  You can have multiple LevelshotReferenceRect nodes, which will result in multiple levelshot images.

##### Other Settings

* Excluded Node Groups - a comma separated list of node groups to exclude.  These nodes are made invisible.
* Include Canvas Layers - CanvasLayer nodes are often used for HUDs and other overlays.  If you do want them in the levelshot, check this option.
* Disable Levelshot for this level - prevents levelshot captures while preserving settings for the level.
* Remove Level - remove the level from Levelshot.  (The level scene itself is NOT touched.)

## How Does It Work (Detail)

It's been asked quite a few times on the internet how to make a screenshot of an entire 2D level in Godot.  For those of you that want/need to roll your own, here's one answer.  Hopefully it works for you.

All that is really needed is to position a 2D camera in the middle of the level, modify the viewport size to reflect the level boundary's aspect ratio and size it to the desired final image size.  Then zoom the camera so that everything is in view and get the texture from the viewport.

### Determining the Level Boundary

The easiest way to determine the level boundary is to set it.  Godot has this handy node called ReferenceRect.  Placing it into the level and sizing it around the visible parts is easy and calculating the level boundary is simple too.  We just need a Rect2 (rectangle) with position and size.  Since the ReferenceRect node is a Control node, it has a global_position and rect_size property.  So we can create a Rect2 with

    var level_boundary = Rect2(ref_rect.global_position, ref_rect.rect_size)

Note that the Levelshot plugin uses a special ReferenceRect, called LevelshotReferenceRect, only because it's easy to identify with it's class name.  Otherwise it's just a ReferenceRect.

But this sucks a little in that you'll have to move the reference rect when you make changes.  So, we can calculate the level boundary by traversing the level node tree, create a rectangle object for each, and merge them all to come up with a final rectangle that encompasses them all.

The process is pretty simple and not too interesting, so that's all I'll describe on that for now.  See the level_extent_calculator.gd script for the code.

### Some Nodes Are Modified/Freed

Some nodes interfere with the capture process.  The biggest offender is other Camera2D nodes.  These are freed from the level.  This is only done at runtime, so it's not hurting anything.  That gives the Camera2D managed by levelshot full reign.

CanvasLayer nodes are hidden by default.  (You can turn this off.)  I personally use CanvasLayer's for HUDs and other overlays, so it seemed best to hide them so you don't see UI in the middle of your glorious levelshot image.

Any node with a node group that's in the Excluded Node Groups list are set to invisible.

Last but not least, all nodes have their pause mode set to PAUSE_MODE_STOP.  This way nodes that you set up to run even when the game is paused are paused during the capture process.


### Calculating Image/Viewport Size

The size of a viewport determines the size of the image you get from it.  Go figure.  So, with a level boundary size determined, we can now do that.

It seems simple scaling the image is the best option.  If you have multiple levels, then you'd want the image size to float along with the relative size of the level.  This is easy to do.  We just set a scale value and do some multiplication on the level boundary Vector2.

    var image_size = level_boundary.size / scale

But what's a good scale factor?  1:10?  That would be 10% the level size, which can result in very small images.  You could just do 1:1 but that might produce huge images.  To get the best scale factor for your game, you would need to experiment.

So, there's the option of just setting an max image size.  It's easier to understand what you'll get.

To get the image size based on a max image size we perform the following calculations:

    var size_ratio = max_size / level_boundary.size
    var uniform_scale_factor = min(size_ratio.x, size_ratio.y)  # this keeps the aspect ratio
    var image_size = level_boundary.size * uniform_scale_factor

### Camera Position and Zoom

It's easy to position the camera in the middle of level.  It's just

    camera2d.global_position = level_boundary.position + level_boundary.size / 2.0

This assumes the level boundary position is also global coordinates.

With the image size calculated above, we can set the camera's zoom.  It's really the reciprocal of the scaling that was done before.  But that can be determined from

    var zoom = level_boundary.size / image_size
    camera2d.zoom = zoom

