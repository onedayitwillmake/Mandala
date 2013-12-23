part of DrawingToolLib;

class PolygonalFillAction extends PolygonalStrokeAction {
  /// @inheritDoc
  static const String ACTION_NAME = "PolygonalFill";

  /// Constructor
  PolygonalFillAction() : super() {
    this.name = ACTION_NAME;
  }

  void execute(dynamic ctx, width, height) {
    settings.execute(ctx);
    executeImp(ctx, BaseAction.DRAWCALL_FILL, width, height );
  }

  void executeForSvg(SvgRenderer ctx, width, height) {
    settings.executeForSvg(ctx);
    ctx.noStroke();
    executeImp(ctx, BaseAction.DRAWCALL_FILL, width, height );
  }
}
