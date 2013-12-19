part of DrawingToolLib;

class SmoothStrokeAction extends RegularStrokeAction {
  static const String ACTION_NAME = "SmoothStroke";

  SmoothStrokeAction() : super() {
    this.name = ACTION_NAME;
  }

  void inputUp(CanvasRenderingContext2D ctx, Point pos) {
    int oldLen = _activePoints.length;
    var simplifiedSmoothedPoints = LineGeneralization.smoothMcMaster( _activePoints );

    points.add(LINE_BREAK);
    points.addAll(simplifiedPoints);

    _activePoints = null;
  }
}