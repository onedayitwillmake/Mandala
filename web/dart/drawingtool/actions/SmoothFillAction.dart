part of DrawingToolLib;

class SmoothFillAction extends SmoothStrokeAction {
  /// @inheritDoc
  static const String ACTION_NAME = "SmoothFill";

  /// Constructor
  SmoothFillAction() : super() {
    this.name = ACTION_NAME;
  }

  void execute(CanvasRenderingContext2D ctx, width, height) {
    settings.execute(ctx);
    executeImp(ctx, ctx.fill, width, height );
  }
}
