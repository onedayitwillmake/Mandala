part of DrawingToolLib;

class RegularStrokeAction extends BaseAction {
  RegularStrokeAction() : super();

  void execute(CanvasRenderingContext2D ctx, width, height) {
    var x = 0;
    var y = 0;
    var radius = 5;
    var color = "red";
    var TAU = PI * 2;

    int max = 10;
//    ctx.translate(width*0.4,10);
    ctx..beginPath()
      ..lineWidth = 2
      ..setStrokeColorHsl(0,80,60)
//      ..setFillColorHsl(120, 80, 50)
//      ..arc(x, y, radius, 0, TAU, false)
//      ..fill()
      ..moveTo(100, 0)
      ..lineTo(200, 0)
      ..stroke()
      ..closePath();
  }

}
