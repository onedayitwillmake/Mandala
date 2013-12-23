part of DrawingToolLib;

class SmoothFillAction extends SmoothStrokeAction {
  /// @inheritDoc
  static const String ACTION_NAME = "SmoothFill";

  /// Constructor
  SmoothFillAction() : super() {
    this.name = ACTION_NAME;
    this.settings.strokeStyle = null;
  }

  void execute(dynamic ctx, width, height) {
    settings.execute(ctx);
    executeImp(ctx, ctx.fill, width, height );
  }
  
  void executeForSvg(SvgRenderer ctx, width, height) {
    settings.executeForSvg(ctx);
    ctx.noStroke();
    executeImp(ctx, ctx.fill, width, height );
  }
}
