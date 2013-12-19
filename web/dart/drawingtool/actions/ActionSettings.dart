part of DrawingToolLib;

class ActionSettings {
  num lineWidth = 0.5;
  num opacity = 0.25;
  String strokeStyle = "rgba(255,255,255,0.25)";
  String fillStyle = "rgba(255,255,255,0.25)";

  ActionSettings();

  void execute(CanvasRenderingContext2D ctx) {
    ctx.lineWidth = lineWidth;
    ctx.setStrokeColorRgb(255, 255, 255,opacity);
    ctx.setFillColorRgb(255,255,255, opacity);
  }
}
