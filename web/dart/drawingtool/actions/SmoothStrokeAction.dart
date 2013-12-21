part of DrawingToolLib;

class SmoothStrokeAction extends RegularStrokeAction {
  static const String ACTION_NAME = "SmoothStroke";

  SmoothStrokeAction() : super() {
    this.name = ACTION_NAME;
  }

  void execute(CanvasRenderingContext2D ctx, width, height) {
    settings.execute(ctx);
    
    // If the active points are not empty - set points to draw to the union of points & activePoints
    List<Point> pointsToDraw = null;
    if( _activePoints != null ) {
      pointsToDraw = new List<Point>.from(points);
      pointsToDraw.add(BaseAction.LINE_BREAK);
      pointsToDraw.addAll( _activePoints );
    } else {
      pointsToDraw = points;
    }

    /// We need at least 2 points
    if( pointsToDraw.isEmpty || pointsToDraw.length < 2 ) return;

    Point start;
    for(var i = 0; i < pointsToDraw.length - 2; i++) {
      
      // Null slot implies a new path should be started
      if( pointsToDraw[i] == BaseAction.LINE_BREAK ) {

        // Close existing path
        if( i != 0 ) {
          ctx.stroke();
          ctx.closePath();
        }

        ctx.beginPath();
        ctx.moveTo( pointsToDraw[i+1].x, pointsToDraw[i+1].y );
        start = pointsToDraw[i+1];
        continue;
      }
      
      Point cp = pointsToDraw[i+1];
      Point end = pointsToDraw[i+2];
      
      // If it's a linebreak, then that means the current point was the last point on this curve
      if( cp == null || cp == BaseAction.LINE_BREAK || end == null || end == BaseAction.LINE_BREAK ) {
        continue;
      }
      
//      cp  = new Point( (start.x+endPoint.x)*0.5, (start.y+endPoint.y)*0.5);
      end = new Point( (pointsToDraw[i].x+cp.x) * 0.5, (pointsToDraw[i].y+cp.y)*0.5);
      cp = pointsToDraw[i]; 
      
//      Point control =  new Point( (pointsToDraw[i].x+endPoint.x)*0.5, (pointsToDraw[i].y+endPoint.y)*0.5);
      ctx.quadraticCurveTo(cp.x, cp.y, end.x, end.y);
//      ctx.arc(cp.x, cp.y, 5, 0, PI * 2, false);
      start = end;
     }
    ctx.stroke();
    ctx.closePath();
  }
  
  void inputUp(CanvasRenderingContext2D ctx, Point pos) {
    int oldLen = _activePoints.length;
    var simplifiedSmoothedPoints =  LineGeneralization.simplifyLang(10, 3, _activePoints) ;//LineGeneralization.smoothMcMaster( LineGeneralization.smoothMcMaster( LineGeneralization.simplifyLang(4, 1, _activePoints) ) );

    print("Removed previously had ${oldLen}, now have ${simplifiedSmoothedPoints.length}, Removed ${oldLen - simplifiedSmoothedPoints.length} points");
    
    points.add(BaseAction.LINE_BREAK);
    points.addAll(simplifiedSmoothedPoints);

    _activePoints = null;
  }
}