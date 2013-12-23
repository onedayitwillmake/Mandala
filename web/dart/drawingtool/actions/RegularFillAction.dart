part of DrawingToolLib;

class RegularFillAction extends RegularStrokeAction {
  /// @inheritDoc
  static const String ACTION_NAME = "RegularFill";

  /// Constructor
  RegularFillAction() : super() {
    this.name = ACTION_NAME;
    this.settings.strokeStyle = null;
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
