import 'dart:html';
import 'dart:math';
import 'dart:svg';
//import 'package:vector_math/vector_math.dart' show Matrix3, Vector2;

import 'drawingtool/DrawingToolLib.dart';

final CanvasRenderingContext2D ctx = (querySelector("#canvas") as CanvasElement).context2D;
int width = 0;
int height = 0;

DrawingTool tool = null;
DrawingToolInterface toolInterface = null;

void main() {
  tool = new DrawingTool( (querySelector("#canvas") as CanvasElement) );
  toolInterface = new DrawingToolInterface( tool );
}