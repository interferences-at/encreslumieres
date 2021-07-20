# Installation instructions

To use this project, in short:
* Download Processing
* Install blobdetective on GNU/Linux. Use it with a modified PlayStation3
  Eye. (for infrared computer vision) - use the proper IP address for OSC
  messages sent by blobdetective
* Burn the firmware on ESP8266 (A wifi chip that can take Arduino code)
  with a force-sensitive sensor (FSR) Make sure to set your wifi credentials
  in the Arduino code before uploading. (also set the IP address to send OSC
  messages to)
* Use a infrared LED so that the camera sees it.
* Run the sketch (potentially comment out Syphon function calls in the main
  file of the Processing sketch.


## Install blobdetective

See https://github.com/interferences-at/blobdetective

## Processing

Download it from the web site.

In the Sketch menu, choose manage libraries...

Download and install the following libraries:

* oscP5
* Syphon
* controlP5


## Ubuntu 15.10

### Processing

Download it from the web site.


### GStreamer

Needed for Processing to work correctly. Yes, they use the old
GStreamer 0.10 version.::

  sudo apt-get install gstreamer0.10-plugins-good

Try a pipeline::

  ls -l /dev/video*
  gst-launch-0.10 v4l2src device=/dev/video1 ! ffmpegcolorspace ! video/x-raw-rgb, width=640, height=480, bpp=32, depth=24 ! ximagesink

## Arduino

* Start the Arduino IDE and open the Preferences window.
* Enter the following URL: http://arduino.esp8266.com/package_esp8266com_index.json 
  into Additional Board Manager URLs field.
* Open Boards Manager from Tools > Board menu and install the esp8266 platform.
* Choose the Olimex MOD-WIFI-ESP8266(-DEV) board type
* Download zip from https://github.com/ameisso/OSCLib-for-ESP8266 and unzip it
  in ~/Documents/Arduino/librairies/ - or better, choose
  Sketch > Include Library > Add .ZIP Library...
