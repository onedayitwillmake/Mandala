part of DrawingToolLib;

class PolygonalFillAction extends PolygonalStrokeAction {
  static const String ACTION_NAME = "PolygonalFill";

  /// Constructor
  PolygonalFillAction() : super() {
    this.name = ACTION_NAME;
  }

  void execute(CanvasRenderingContext2D ctx, width, height) {
    executeImp(ctx, ctx.fill, width, height );
  }
}
