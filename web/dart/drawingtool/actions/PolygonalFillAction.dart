part of DrawingToolLib;

class PolygonalFillAction extends PolygonalStrokeAction {
  /// @inheritDoc
  static const String ACTION_NAME = "PolygonalFill";

  /// Constructor
  PolygonalFillAction() : super() {
    this.name = ACTION_NAME;
  }

  void execute(CanvasRenderingContext2D ctx, width, height) {
    settings.execute(ctx);
    executeImp(ctx, ctx.fill, width, height );
  }

  void executeForSvg(Abstract2DRenderingContext ctx, width, height) {
    settings.executeForSvg(ctx);
//    executeImp(ctx, ctx.fill, width, height );
  }
}
