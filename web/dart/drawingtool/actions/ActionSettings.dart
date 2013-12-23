part of DrawingToolLib;

class ActionSettings {
  num lineWidth = 0.5;
  num opacity = 0.5;
  String strokeStyle = "rgba(255,255,255,0.25)";
  String fillStyle = "rgba(255,255,255,0.25)";

  ActionSettings();

  void execute(dynamic ctx) {
    ctx.lineWidth = lineWidth;
    ctx.setStrokeColorRgb(255, 255, 255,opacity);
    ctx.setFillColorRgb(255,255,255, opacity);
  }

  void executeForSvg(SvgRenderer ctx) {
    ctx.lineWidth = lineWidth;
    if( strokeStyle == null ) {
      ctx.noStroke();
    } else {
      ctx.setStrokeColorRgb(255,255,255,opacity);
    }

    if( fillStyle == null ) {
      ctx.noFill();
    } else {
      ctx.setFillColorRgb(255,255,255,opacity);
    }
  }
}
