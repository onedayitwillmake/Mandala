import 'dart:html';
import 'drawingtool/DrawingToolLib.dart';

final CanvasRenderingContext2D ctx = (querySelector("#canvas") as CanvasElement).context2D;
int width = 0;
int height = 0;

DrawingTool tool = null;
DrawingToolInterface toolInterface = null;

void main() {
  print("HelloDartWorld!");
  tool = new DrawingTool( (querySelector("#canvas") as CanvasElement) );
  toolInterface = new DrawingToolInterface( tool );
}