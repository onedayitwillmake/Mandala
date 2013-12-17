part of DrawingToolLib;

class RegularStrokeAction extends BaseAction {
  RegularStrokeAction() : super();

  void execute(CanvasRenderingContext2D ctx, width, height) {
    if( points.isEmpty) return;
    var x = points.last.x;
    var y = points.last.y;
    var radius = 5;
    var color = "red";
    var TAU = PI * 2;

    ctx..beginPath()
      ..lineWidth = 2
      ..setFillColorHsl(0, 80, 50)
      ..arc(x, y, radius, 0, TAU, false)
      ..fill()
      ..closePath();
    return;

    ctx.beginPath()
    ..lineWidth = 2
    ..setStrokeColorHsl(0, 80, 60)
    ..moveTo(points[0].x, points[0].y);
    for (int i = 1; i < points.length; i++) {
      ctx.lineTo(points[i].x, points[i].x);
    }
    ctx.stroke();
    ctx.closePath();

    print(points.length);
  }

  void inputDown(CanvasRenderingContext2D ctx, Point pos) {
    points = [pos];
  }

  void inputMove(CanvasRenderingContext2D ctx, Point pos) {
    points.add(pos);
  }

  void inputUp(CanvasRenderingContext2D ctx, Point pos) {
    points.add(pos);
  }
}
