// XXX comment out next line if not using Syphon (macOS-only)
//import codeanticode.syphon.SyphonServer;

// XXX comment out next line if not using Spout (Windows-only)
// import spout.*;

// constants
//final String SYPHON_SERVER_NAME = "encres&lumieres";
final String SPOUT_SERVER_NAME = "encres&lumieres";
final boolean VERBOSE = false;
final int OSC_RECEIVE_PORT = 8888;

// variables
App app;
// XXX comment out next line if not using Syphon (macOS-only)
//SyphonServer syphon_server;

// XXX comment out next line if not using Spout (Windows-only)
// Spout spout;

void settings() {
  size(1920, 1080, P3D);
  // XXX comment out next line if not using Syphon (macOS-only)
  //PJOGL.profile = 1;
}

void setup() {
  frameRate(60);
  app = new App();
  app.set_osc_receive_port(OSC_RECEIVE_PORT);
  app.set_verbose(VERBOSE);
  app.set_sketch_size(width, height);
  app.setup_cb();
  
  // XXX comment out next line if not using Syphon (macOS-only)
  // syphon_server = new SyphonServer(this, SYPHON_SERVER_NAME);

  // XXX comment out next line if not using Spout (Windows-only)
  // spout = new Spout(this);
}

void draw() {
  app.draw_cb(mouseX, mouseY);
 // XXX comment out next line if not using Syphon (macOS-only)
 // syphon_server.sendScreen();

 // XXX comment out next line if not using Spout (Windows-only)
 // spout.sendTexture();
}

void mousePressed() {
  app.mousePressed_cb(mouseX, mouseY);
}

void mouseReleased() {
  app.mouseReleased_cb(mouseX, mouseY);
}

void keyPressed() {
  app.keyPressed_cb();
}

void keyReleased() {
  app.keyReleased_cb();
}

