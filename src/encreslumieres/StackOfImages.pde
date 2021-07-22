/**
 * List of images we can use to paint.
 */
class StackOfImages {
  private int _amount;
  private int _current;
  private PImage[] _img;
  
  public StackOfImages(int amountOfImages, int images_width, int images_height) {
    this._amount = amountOfImages;
 
    // Initialize all images as copies of the current display
    this._img = new PImage[this._amount];
    for (int i = 0; i < this._amount; i++) {
      this._img[i] = createImage(images_width, images_height, RGB);
      this._img[i] = get();
    }
  }
  
  public void next() {
    this._current = (this._current + 1) % this._amount;
  }
  
  public void previous() {
    this._current = (this._current - 1 + this._amount) % this._amount;
  }
  
  public void capture(PGraphics screen) {
    this._img[this._current] = screen.get();
  }
  
  public void show(PGraphics screen) {
    screen.image(this._img[this._current], 0, 0);
  }
  
  public int get_amount() {
    return this._amount;
  }
}

