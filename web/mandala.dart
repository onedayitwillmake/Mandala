import 'dart:html';
import 'dart:math';
import 'dart:svg';
//import 'package:vector_math/vector_math.dart' show Matrix3, Vector2;

import 'drawingtool/DrawingToolLib.dart';

final CanvasRenderingContext2D ctx = (querySelector("#canvas") as CanvasElement).context2D;
int width = 0;
int height = 0;

DrawingTool tool = null;

void main() {
  tool = new DrawingTool( (querySelector("#canvas") as CanvasElement) );
//
//  width = canvas.width;
//  height = canvas.height;
//
//  var x = 0;
//  var y = 0;
//  var radius = 5;
//  var color = "red";
//  var TAU = PI * 2;
//
//  ctx.clearRect(0, 0, width, height);
//  CanvasGradient gradient = ctx.createRadialGradient(width*0.5, height*0.5, 0, width*0.5, height*0.5, width*0.5);
//  gradient.addColorStop(0, '#383245');
//  gradient.addColorStop(1, '#1B1821');
//  ctx.fillStyle = gradient;
//  ctx.fillRect(0,0,width,height);
//
//  int max = 10;
//  for(int i = 0; i < 10; i++) {
//    ctx.setTransform(1, 0, 0, 1, width*0.5, height*0.5);
//    ctx.rotate(i/max * TAU);
//    ctx.translate(width*0.4,10);
//    ctx..beginPath()
//      ..lineWidth = 2
//      ..setFillColorHsl(i/max * 360, 80, 50)
//      ..arc(x, y, radius, 0, TAU, false)
//      ..fill()
//      ..closePath();
//  }
}