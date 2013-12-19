part of DrawingToolLib;

class ActionSettings {
  num lineWidth = 0.5;
  String strokeStyle = "rgba(255,255,255,0.25)";
  String fillStyle = "rgba(255,255,255,0.25)";

  ActionSettings();

  void execute(CanvasRenderingContext2D ctx) {
    ctx.lineWidth = lineWidth;
    ctx.strokeStyle = strokeStyle;
    ctx.fillStyle = fillStyle;
  }
}
