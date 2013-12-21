part of DrawingToolLib;

class RegularFillAction extends RegularStrokeAction {
  /// @inheritDoc
  static const String ACTION_NAME = "RegularFill";

  /// Constructor
  RegularFillAction() : super() {
    this.name = ACTION_NAME;
  }

  void execute(CanvasRenderingContext2D ctx, width, height) {
    settings.execute(ctx);
    executeImp(ctx, ctx.fill, width, height );
  }
}
