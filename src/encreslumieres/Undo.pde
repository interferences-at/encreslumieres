/**
 * Manages the undo stack.
 */
class Undo
{
  // Number of currently available undo and redo snapshots
  private int _undo_steps = 0;
  private int _redo_steps = 0;
  private StackOfImages _images;
 
  public Undo(int levels, int images_width, int images_height)
  {
    this._images = new StackOfImages(levels, images_width, images_height);
  }
 
  public void take_snapshot(PGraphics screen)
  {
    this._undo_steps = min(this._undo_steps + 1, this._images.get_amount() - 1);
    // each time we draw we disable redo
    this._redo_steps = 0;
    this._images.next();
    this._images.capture(screen);
  }
  
  public void undo(PGraphics screen)
  {
    int LAST_UNDO_STEP = 1;  // used to be 0
    // but it was causing a blank grey image at the last undo level
    if (this._undo_steps > LAST_UNDO_STEP)
    {
      this._undo_steps --;
      this._redo_steps ++;
      this._images.previous();
      this._images.show(screen);
    }
  }
  
  public void redo(PGraphics screen)
  {
    if (this._redo_steps > 0)
    {
      this._undo_steps ++;
      this._redo_steps --;
      this._images.next();
      this._images.show(screen);
    }
  }
}
