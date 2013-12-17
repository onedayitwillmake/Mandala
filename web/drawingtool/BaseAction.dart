part of DrawingToolLib;

class BaseAction {
  List<Point> points = new List<Point>();

  void inputDown(CanvasRenderingContext2D ctx, Point pos){}
  void inputMove(CanvasRenderingContext2D ctx, Point pos){}
  void inputUp(CanvasRenderingContext2D ctx, Point pos){}
  void execute(CanvasRenderingContext2D ctx, width, height){}
}