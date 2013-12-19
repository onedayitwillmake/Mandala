part of DrawingToolLib;

class RegularStrokeAction extends BaseAction {
  static const String ACTION_NAME = "RegularStroke";

  static Point  LINE_BREAK = new Point(null, null);
  List<Point> _activePoints = null;

  /// Constructor
  RegularStrokeAction() : super( ACTION_NAME );

  /// Draw a series of simple strokes
  void execute(CanvasRenderingContext2D ctx, width, height) {

    // If the active points are not empty - set points to draw to the union of points & activePoints
    List<Point> pointsToDraw = null;
    if( _activePoints != null ) {
      pointsToDraw = new List<Point>.from(points);
      pointsToDraw.add(LINE_BREAK);
      pointsToDraw.addAll( _activePoints );
    } else {
      pointsToDraw = points;
    }

    if( pointsToDraw.isEmpty || pointsToDraw.length < 2 ) return;

    for(var i = 0; i < pointsToDraw.length; i++) {
      // Null slot implies a new path should be started
      if( pointsToDraw[i] == LINE_BREAK ) {

        // Close existing path
        if( i != 0 ) {
          ctx.stroke();
          ctx.closePath();
        }

        ctx.beginPath();
        ctx.moveTo( pointsToDraw[i+1].x, pointsToDraw[i+1].y );
        continue;
      }

      ctx.lineTo( pointsToDraw[i].x, pointsToDraw[i].y );
    }
    ctx.stroke();
    ctx.closePath();
  }

  void inputDown(CanvasRenderingContext2D ctx, Point pos) {
    _activePoints = new List<Point>();
    _activePoints.add(pos);
  }

  void inputMove(CanvasRenderingContext2D ctx, Point pos, bool isDrag) {
    if( !isDrag ) return;
    _activePoints.add(pos);
  }

  void inputUp(CanvasRenderingContext2D ctx, Point pos) {
    int oldLen = _activePoints.length;
    var simplifiedPoints = LineGeneralization.simplifyLang(5, 1, _activePoints);
    print("Removed ${oldLen - simplifiedPoints.length} points");

    points.add(LINE_BREAK);
    points.addAll(simplifiedPoints);

    _activePoints = null;
  }
}
