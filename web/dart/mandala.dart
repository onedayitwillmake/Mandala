import 'dart:html';
import 'drawingtool/drawingtoollib.dart';
import 'site/sitelib.dart';

final CanvasRenderingContext2D ctx = (querySelector("#canvas") as CanvasElement).context2D;
int width = 0;
int height = 0;

DrawingTool tool = null;
DrawingToolInterface toolInterface = null;

void main() {
  if( querySelector("#canvas") != null ) {
    tool = new DrawingTool( (querySelector("#canvas") as CanvasElement) );
    toolInterface = new DrawingToolInterface( tool );
  }

  var site = new SiteApp(tool);
}