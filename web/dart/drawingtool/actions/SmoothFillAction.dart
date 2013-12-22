part of DrawingToolLib;

class SmoothFillAction extends SmoothStrokeAction {
  /// @inheritDoc
  static const String ACTION_NAME = "SmoothFill";

  /// Constructor
  SmoothFillAction() : super() {
    this.name = ACTION_NAME;
    this.settings.strokeStyle = null;
  }

  void execute(CanvasRenderingContext2D ctx, width, height) {
    settings.execute(ctx);
    executeImp(ctx, ctx.fill, width, height );
  }
  
  void executeForSvg(Abstract2DRenderingContext ctx, width, height) {
    settings.executeForSvg(ctx);
    ctx.noStroke();
    executeForSvgImp(ctx, ctx.fill, width, height);
  }
}
