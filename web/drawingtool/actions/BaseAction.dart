part of DrawingToolLib;

class BaseAction {
  
  /// Name of this action, for example "RegularStroke"
  static const String ACTION_NAME = null;
  
  /// A null point, inserted into this objects points array.
  /// Each subclasses might use this to denote something unique about itself, for example - break the line or start a new path 
  static Point LINE_BREAK = new Point(null, null);
  
  /// Points used by this object
  List<Point> points = new List<Point>();
  
  /// This actions name is equal to ACTION_NAME for it's class
  String name = null;
  
  /// Stored settings for this action, such as opacity, color, etc
  ActionSettings settings = new ActionSettings();
  
  BaseAction( this.name );
  
  void inputDown(CanvasRenderingContext2D ctx, Point pos){}
  void inputMove(CanvasRenderingContext2D ctx, Point pos, bool isDragging ){}
  void inputUp(CanvasRenderingContext2D ctx, Point pos){}
  void keyPressed(CanvasRenderingContext2D ctx, KeyboardEvent e ){}
  void execute(CanvasRenderingContext2D ctx, width, height){}
  void activeDraw(CanvasRenderingContext2D ctx, width, height){}
  void undo(CanvasRenderingContext2D ctx ){}
}