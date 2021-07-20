/**
 * Brush that paints with a shader.
 */
class PointShaderBrush extends Brush
{
  private PShader _point_shader;
  // Spray density distribution expressed in grayscale gradient
  private PImage _spray_map;
  
  public PointShaderBrush()
  {
    super();
    this._spray_map = loadImage("sprayMap.png");
    this._point_shader = loadShader("pointfrag.glsl", "pointvert.glsl");  
    //_point_shader.set("sharpness", 0.9);
    this._point_shader.set("sprayMap", this._spray_map);
  }
  
  public final void draw_brush(PGraphics buffer, float x, float y, float size, color colour)
  {
    PVector dir = new PVector(x, y);
    dir.normalize();
    float noiseDepth = random(1.0);  // for spray pattern generation // FIXME: used to be a member of Knot/Node
    
    //buffer.pushStyle();
    buffer.strokeCap(SQUARE);
    
    this._point_shader.set("weight", size);
    this._point_shader.set("direction", dir.x, dir.y);
    this._point_shader.set("rotation", random(0.0, 1.0), random(0.0, 1.0));
    this._point_shader.set("scale", 0.3); 
    this._point_shader.set("soften", 1.0); // towards 0.0 for harder brush, towards 2.0 for lighter brush
    this._point_shader.set("depthOffset", noiseDepth);

    buffer.strokeWeight(size);
    buffer.stroke(colour);
    buffer.shader(this._point_shader, POINTS);
    buffer.point(x, y); 

    //buffer.popStyle();
  }
}
