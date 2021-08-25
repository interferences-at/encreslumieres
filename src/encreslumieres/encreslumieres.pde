// XXX Uncomment if using Syphon (macOS-only)
//import codeanticode.syphon.SyphonServer;

// XXX Uncomment if using Spout (Windows-only)
// import spout.*;

final String SYPHON_SERVER_NAME = "encres&lumieres";
final String SPOUT_SERVER_NAME = "encres&lumieres";
final int OSC_RECEIVE_PORT = 8888;
final String renderer = P2D;
final int WINDOW_WIDTH = 1920;
final int WINDOW_HEIGHT = 1080;
App app;

// XXX Uncomment if using Syphon (macOS-only)
//SyphonServer syphon_server;

// XXX Uncomment if using Spout (Windows-only)
// Spout spout;

void settings() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT, renderer);

  // XXX Uncomment if using Syphon (macOS-only)
  // PJOGL.profile = 1;
}

void setup() {
  frameRate(60);
  app = new App(width, height, renderer);
  app.set_osc_receive_port(OSC_RECEIVE_PORT); // Must be called before app.setup_cb()
  app.set_sketch_size(width, height);
  app.setup_cb(); // Make sure to call app.set_osc_receive_port(...) first.
  
  // XXX Uncomment if using Syphon (macOS-only)
  // syphon_server = new SyphonServer(this, SYPHON_SERVER_NAME);

  // XXX Uncomment if using Spout (Windows-only)
  // spout = new Spout(this);
}

void draw() {
  app.draw_cb(mouseX, mouseY);
  
 // XXX Uncomment if using Syphon (macOS-only)
 // syphon_server.sendScreen();

 // XXX Uncomment if using Spout (Windows-only)
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
