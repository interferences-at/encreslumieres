# Encres & Lumieres release notes

## 2021-08-26 - 2.0.0
- Rename SprayCan to Painter
- Use the P2D renderer for the layers.
- Separate the layers from the painters.
- Remove linked strokes.
- Remove the undo.
- Attempt to fix the undesired dark contour effect around each stroke.
- Refactor of the OSC for the new devices:

To trigger the painter, it used to be:

```
/force ii
```

We now have:

```
/1/raw ,ffffffffffffffffffffff - 12:force
/2/raw ,ffffffffffffffffffffff - 12:force
/3/raw ,ffffffffffffffffffffff - 12:force
/4/raw ,ffffffffffffffffffffff - 12:force
/5/raw ,ffffffffffffffffffffff - 12:force
```

For the position of the spray can, it used to be:

```
/blob ,ifff - 1:x 2:y 3:size
```

We now have:

```
/blob ,iiii - 1:x 2:y 3:size
```

The input dimension is 720x480. (it was 640x480)

The force is now within 0-1070 and the threshold is 300.
(it was within 0-1023, and the threshold was 50)


## 2016-06-05 - 1.0.0

* Fix bug #1: Strokes are sometimes linked between their end and beginning
* Fix bug #5: ArrayIndexOutOfBoundsException
* Support alpha in /color
* Add /brush/choice
* Add /clear
* Many spray can drawing strokes at the same time
* Use integers for spray can identifiers
* change default step size to 1.0 - it will be slower
* Add /link_strokes - link strokes with a straight line
* add /layer
* implement scale center and factor
* add MANUAL.txt
* add /set/step_size
* add EraserBrush
* FIX: bug #8 The EraserBrush makes pixels darker afterwhile
* map force to alpha ratio
* transparent background for syphon textures
* add a multi-image brush
* Improve the look of the cursor


## 2016-04-05 - 0.2.0

* Can now draw in color with OSC
* Use /brush/weight for the size of the brush.
* Add colorpicker.pde - sends the OSC /color message
* move blobdetector.pde to prototypes (since we now use blobdetector, a C++ app)


## 2016-03-28 - 0.1.0

* One color spray painting shader
* Arduino force sensor - sends OSC
* Blob tracking - see the blobdetective project

