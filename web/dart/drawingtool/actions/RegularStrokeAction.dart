part of DrawingToolLib;

class RegularStrokeAction extends BaseAction {
  static const String ACTION_NAME = "RegularStroke";

  List<Geom.Point> _activePoints = null;

    /// Constructor
  RegularStrokeAction() : super(ACTION_NAME);

    /// Draw a series of simple strokes
  void execute(dynamic ctx, width, height) {
    settings.execute(ctx);
    executeImp(ctx, ctx.stroke, width, height);
  }

  void executeImp(dynamic ctx, Function drawCall, width, height) {

    // If the active points are not empty - set points to draw to the union of points & activePoints
    List<Geom.Point> pointsToDraw = _getPointsToDraw();
      /// We need at least 2 points
    if (pointsToDraw.isEmpty || pointsToDraw.length < 2) return;

    for (var i = 0; i < pointsToDraw.length; i++) {

      // Null slot implies a new path should be started
      if (pointsToDraw[i] == BaseAction.LINE_BREAK) {

      // Close existing path
        if (i != 0) {
          drawCall();
          ctx.closePath();
        }

        ctx.beginPath();
        ctx.moveTo(pointsToDraw[i + 1].x, pointsToDraw[i + 1].y);
        continue;
      }

      ctx.lineTo(pointsToDraw[i].x, pointsToDraw[i].y);
    }
    drawCall();
    ctx.closePath();
  }

  /**
  * Special rendering function to work with SVGRenderer
  */
  void executeForSvg(Abstract2DRenderingContext ctx, width, height) {
    settings.executeForSvg(ctx);
    ctx.noFill();
    executeImp(ctx, ctx.stroke, width, height);
  }

  void inputDown(dynamic ctx, Geom.Point pos, bool canEditPoints) {
    _activePoints = new List<Geom.Point>();
    _activePoints.add(pos);
  }

  void inputMove(dynamic ctx, Geom.Point pos, bool isDrag) {
    if (!isDrag) return;
    _activePoints.add(pos);
  }

  void inputUp(dynamic ctx, Geom.Point pos) {
    int oldLen = _activePoints.length;
    var simplifiedPoints = LineGeneralization.simplifyLang(4, 0.5, _activePoints);

    print("Had: ${oldLen}, Have: ${simplifiedPoints.length}, Removed ${oldLen - simplifiedPoints.length} points");

    points.add(BaseAction.LINE_BREAK);
    points.addAll(simplifiedPoints);

    _activePoints = null;
  }

  List<Geom.Point> _getPointsToDraw() {
    if (_activePoints != null) {
      List<Geom.Point> pointsToDraw = new List<Geom.Point>.from(points);
      pointsToDraw.add(BaseAction.LINE_BREAK);
      pointsToDraw.addAll(_activePoints);
      return pointsToDraw;
    } else {
      return points;
    }
  }

  void undo(dynamic ctx) {
    int lastBreak = points.lastIndexOf(BaseAction.LINE_BREAK);
    if (lastBreak == -1) return;
    points.removeRange(lastBreak, points.length);
  }
}
