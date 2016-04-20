import 'dart:html';
import 'drawingtool/drawingtoollib.dart';

final CanvasRenderingContext2D ctx = (querySelector("#canvas") as CanvasElement).context2D;
int width = 0;
int height = 0;

DrawingTool tool = null;
DrawingToolInterface toolInterface = null;

void main() {
  print("1!");
  tool = new DrawingTool( (querySelector("#canvas") as CanvasElement) );
  toolInterface = new DrawingToolInterface( tool );
}