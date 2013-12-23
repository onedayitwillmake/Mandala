part of DrawingToolLib;

abstract class Abstract2DRenderingContext {
  // Core
  void moveTo(num x, num y);
  void lineTo(num x, num y);
  void quadraticCurveTo(num cpx, num cpy, num x, num y);
  
  // Matrix Transform
  void setTransform(num m11, num m12, num m21, num m22, num dx, num dy);
  void translate(num tx, num ty);
  void rotate(num angle);
  
  // Shapes
  void arc(num x,  num y,  num radius,  num startAngle, num endAngle, [bool anticlockwise = false]);
  void rect(num x, num y, num width, num height);
  
  // Path Begin/Close
  void beginPath();
  void closePath();
  
  // Fill/Stroke
  void stroke();
  void noStroke();
  
  void fill();
  void noFill();

  // Color
  void setStrokeColorRgb(int r, int g, int b, [num a = 1]);
  void setStrokeColorHsl(int h, num s, num l, [num a = 1]);
  void setFillColorRgb(int r, int g, int b, [num a = 1]);
  void setFillColorHsl(int h, num s, num l, [num a = 1]);

  // Props
  num   get lineWidth;
        set lineWidth(num value);

  String  get fillStyle;
          set fillStyle( String value );

  String  get strokeStyle;
          set strokeStyle( String value );
}