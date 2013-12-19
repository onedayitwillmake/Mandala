part of DrawingToolLib;

class SettingsAction extends BaseAction {
  static const String ACTION_NAME = "Settings";

  String lineWidth = 0.5;
  String strokeStyle = "rgba(255,255,255,0.25)";
  String fillStyle = "rgba(255,255,255,0.25)";

  SettingsAction() : super( ACTION_NAME ) {
    points = null;
  }

  void execute(CanvasRenderingContext2D ctx, width, height) {
    ctx.lineWidth = lineWidth;
    ctx.strokeStyle = strokeStyle;
    ctx.fillStyle = fillStyle;
  }
}
