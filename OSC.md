# OSC message signatures for Encres & Lumieres

Notes:
* Use 0 for the default spray identifier. (the one controlled by the mouse)
* Often, either float or int arguments are accepted. (but they must all be either float or int)


## blob

Signature:
* `/blob ,iiii`

Arguments:
* Argument 1: spray identifier.
* Argument 2: x [0-640]
* Argument 3: y [0-480]
* Argument 4: size [0-1000]

Description:
The blob is the position of the infrared LED as seen by the video camera. Its
position moves around the brush.
See the blobdetective software.


## /N/raw - force

Signature:
* `/1/raw ,ffffffffffffffffffffff`
* `/2/raw ,ffffffffffffffffffffff`
* `/3/raw ,ffffffffffffffffffffff`
* `/4/raw ,ffffffffffffffffffffff`
* `/5/raw ,ffffffffffffffffffffff`

The path includes the spray identifier

Arguments:
* Argument 12: force [0-1023] - If it's > 300, it means it's pressed.

Description:
The force is used as an on/off/amount controller for painting.

Its odd OSC signature is due to the fact that it's the format of the messages we receive from the BITalino R-IoT, a microcontroller that sends OSC via wifi, and that also contains onboard sensors, such as an accelerometer and a gyroscope.

## color

Signatures:
* `/color ,iffff`
* `/color ,iiiii`

Arguments:
* Argument 1: spray identifier.
* Argument 2: red [0-255]
* Argument 3: green [0-255]
* Argument 4: blue [0-255]
* Argument 5: alpha [0-255]

Description:
Sets the color of a brush.


## brush weight

Signatures:
* `/brush/weight ,ii`
* `/brush/weight ,if`

Arguments:
* Argument 1: spray identifier.
* Argument 2: brush weight. The default is 100. This will change the size of the brush.

Description:
Sets the weight of a brush.

## brush choice

Signatures:
* `/brush/choice ,ii`
* `/brush/choice ,if`

Arguments:
* Argument 1: spray identifier.
* Argument 2: brush choice. Brushes are numbered 0, 1, 2, 3, etc.

Description:
Sets the choice of brush.

Brush 0 is a point shader. Brush 1, 2, 3, etc. are PNG files, randomly rotated.

Brush 14 is an eraser. The size of the eraser is the same as the brushes.


## undo

Signature:
`/undo ,i`

Arguments:
* Argument 1: spray identifier.

Description:
Undos the last stroke that ended.


## redo

Signature:
`/redo ,i`

Arguments:
* Argument 1: spray identifier.

Description:
Redos the last thing undone. (see /undo)


## set force threshold

Signature:
`/set/force/threshold ,i`

Arguments:
* Argument 1: value

Description:
Changes the FSR sensor on/off threshold value.
It's the same for all spray cans.


## set step size

Signature:
`/set/step_size, if`

Arguments:
* Argument 1: spray identifier

Description:
Sets the minimum distance between interpolated positions of nodes. (in pixels)


## scale factor

Signature:
`/scale/factor, if`

Arguments:
* Argument 1: spray identifier
* Argument 2: factor

Description:
Sets the scale factor (within the range [0,1]) for a spray can.
The default is 1.0
A scale factor of 1.0 means that we use the full sketch area.
A scale factor of 0.1 means that we can only paint in 1/10 of the sketch area.


## scale center

Signature:
`/scale/center, iff`

Arguments:
* Argument 1: spray identifier
* Argument 2: center x (in the range [0,1])
* Argument 3: center y (in the range [0,1])

Description:
Sets the scale center (within the range [0,1]) for a spray can.
The default is (0.5, 0.5)
For the Y scale, 0.0 is the top of the sketch and 1.0 is the bottom.
For the X scale, 0.0 is the left of the sketch and 1.0 is the right.


## layer

Signature:
`/layer ,ii`

Arguments:
* Argument 1: spray identifier
* Argument 2: layer number (within the range [0,9]

Description:
Sets the layer for a spray can.
The default for all spray cans is 0.
If the layer of a spray is 9, it will be drawn over all spray cans whose layer
number if smaller than 9.


## link strokes

Signature:
`/link_strokes ,ii`

Arguments:
* Argument 1: spray identifier
* Argument 2: enable it (1 enables it, 0 disables it)

Description:
Enables of disables the linked strokes for a spray can.
The default for all spray cans is disabled.
Every new stroke will be linked to the previous one with a straigth line, if
enabled.
