part of DrawingToolLib;

class BaseAction {
  
  /// Name of this action, for example "RegularStroke"
  static const String ACTION_NAME = null;

  static const int MIN_DRAG_DISTANCE = 4;

  /// A null point, inserted into this objects points array.
  /// Each subclasses might use this to denote something unique about itself, for example - break the line or start a new path 
  static Geom.Point LINE_BREAK = new Geom.Point(null, null);
  
  /// Points used by this object
  List<Geom.Point> points = new List<Geom.Point>();
  
  /// This actions name is equal to ACTION_NAME for it's class
  String name = null;
  
  /// Stored settings for this action, such as opacity, color, etc
  ActionSettings settings = new ActionSettings();
  
  BaseAction( this.name );
  
  void inputDown(CanvasRenderingContext2D ctx, Geom.Point pos, bool canEditPoints ){}
  void inputMove(CanvasRenderingContext2D ctx, Geom.Point pos, bool isDragging ){}
  void inputUp(CanvasRenderingContext2D ctx, Geom.Point pos){}
  void keyPressed(CanvasRenderingContext2D ctx, KeyboardEvent e ){}
  void execute(CanvasRenderingContext2D ctx, width, height){}
  void executeForSvg(Abstract2DRenderingContext ctx, width, height){}
  void activeDraw(CanvasRenderingContext2D ctx, width, height, bool canEditPoints){}
  void undo(CanvasRenderingContext2D ctx ){}
}