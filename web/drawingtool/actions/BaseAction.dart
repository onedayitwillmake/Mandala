part of DrawingToolLib;

class BaseAction {
  static const String ACTION_NAME = null;

  List<Point> points = new List<Point>();
  String name = null;

  BaseAction( this.name );

  void inputDown(CanvasRenderingContext2D ctx, Point pos){}
  void inputMove(CanvasRenderingContext2D ctx, Point pos, bool isDragging ){}
  void inputUp(CanvasRenderingContext2D ctx, Point pos){}
  void execute(CanvasRenderingContext2D ctx, width, height){}
}