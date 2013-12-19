part of DrawingToolLib;

class SmoothStrokeAction extends RegularStrokeAction {
  static const String ACTION_NAME = "SmoothStroke";

  SmoothStrokeAction() : super() {
    this.name = ACTION_NAME;
  }

  void inputUp(CanvasRenderingContext2D ctx, Point pos) {
    int oldLen = _activePoints.length;
    var simplifiedSmoothedPoints = LineGeneralization.smoothMcMaster( LineGeneralization.simplifyLang(5, 1, _activePoints) );

    print("Removed previously had ${oldLen}, now have ${simplifiedSmoothedPoints.length}, Removed ${oldLen - simplifiedSmoothedPoints.length} points");


    points.add(BaseAction.LINE_BREAK);
    points.addAll(simplifiedSmoothedPoints);

    _activePoints = null;
  }
}