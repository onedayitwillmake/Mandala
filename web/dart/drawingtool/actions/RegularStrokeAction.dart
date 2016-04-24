part of DrawingToolLib;

class RegularStrokeAction extends BaseAction {
  static const String ACTION_NAME = "RegularStroke";

  /// Storage for points currently being drawn but not yet commited
  List<Geom.Point> _activePoints = null;

  RegularStrokeAction() : super(ACTION_NAME);

  /// Draw a series of simple strokes
  void execute(dynamic ctx, width, height) {
    settings.execute(ctx);
    executeImp(ctx, BaseAction.DRAWCALL_STROKE, width, height);
  }

  /// Special rendering function to work with SVGRenderer
  void executeForSvg(SvgRenderer ctx, width, height) {
    settings.executeForSvg(ctx);
    ctx.noFill();
    executeImp(ctx, BaseAction.DRAWCALL_STROKE, width, height);
  }

  void executeImp(dynamic ctx, int drawCall, width, height) {

    // If the active points are not empty - set points to draw to the union of points & activePoints
    List<Geom.Point> pointsToDraw = _getPointsToDraw();
      /// We need at least 2 points
    if (pointsToDraw.isEmpty || pointsToDraw.length < 2) return;

    for (var i = 0; i < pointsToDraw.length; i++) {

      // Null slot implies a new path should be started
      if (pointsToDraw[i] == BaseAction.LINE_BREAK) {

      // Close existing path
        if (i != 0) {
          // Tmp hack for dart2js function ref issue 15782
          drawCall == BaseAction.DRAWCALL_FILL ? ctx.fill() : ctx.stroke();
          ctx.closePath();
        }

        ctx.beginPath();
        ctx.moveTo(pointsToDraw[i + 1].x, pointsToDraw[i + 1].y);
        continue;
      }

      ctx.lineTo(pointsToDraw[i].x, pointsToDraw[i].y);
    }
    // Tmp hack for dart2js function ref issue 15782
    drawCall == BaseAction.DRAWCALL_FILL ? ctx.fill() : ctx.stroke();
    ctx.closePath();
  }



  void inputDown(Geom.Point pos, bool canEditPoints) {
    _activePoints = new List<Geom.Point>();
    _activePoints.add(pos);
  }

  void inputMove(Geom.Point pos, bool isDrag) {
    if (!isDrag) return;
    _activePoints.add(pos);
  }

  void inputUp(Geom.Point pos) {
    int oldLen = _activePoints.length;
    var simplifiedPoints = LineGeneralization.simplifyLang(4, 0.5, _activePoints);

    points.add(BaseAction.LINE_BREAK);
    points.addAll(simplifiedPoints);

    _activePoints = null;
    onComplete();
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

  void undo() {
    int lastBreak = points.lastIndexOf(BaseAction.LINE_BREAK);
    if (lastBreak == -1) return;
    points.removeRange(lastBreak, points.length);
  }
}
