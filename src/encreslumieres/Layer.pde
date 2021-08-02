/**
 * A layer spray cans can draw on.
 */
class Layer {

  // attributes
  private PGraphics _buffer = null; // Our pixel buffer.
  private int _image_width; // sketch size
  private int _image_height; // sketch size

  /**
   * Constructor.
   */
  public Layer(int image_width, int image_height) {
    this._image_width = image_width;
    this._image_height = image_height;
    this.clear_all(); // Creates the this._buffer
  }

  /**
   * Display the contents of this layer.
   */
  public void draw_layer() {
    image(this._buffer, 0, 0);
  }

  /**
   * Clears this whole layer.
   */
  public void clear_all() {
    this._buffer = createGraphics(this._image_width, this._image_height);
    this._buffer.colorMode(RGB, 255);
    this._buffer.beginDraw();
    this._buffer.background(0, 0, 0, 0); // Transparent black.
    this._buffer.endDraw();
  }
}
