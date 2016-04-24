import 'dart:html';
import 'drawingtool/drawingtoollib.dart';
import 'dart:async';
import 'dart:js';
import 'site/sitelib.dart';

final CanvasRenderingContext2D ctx = (querySelector("#canvas") as CanvasElement).context2D;
int width = 0;
int height = 0;
int rafId = -1;

DrawingTool tool = null;
DrawingToolInterface toolInterface = null;

void main() {
//  if( querySelector("#canvas") != null ) {
//    tool = new DrawingTool( (querySelector("#canvas") as CanvasElement) );
//    toolInterface = new DrawingToolInterface( tool );
//  }

//  var jqueryWaitFn = () => {
//    print(window.jQuery)
//  };

//  new Future.delayed(new Duration(seconds:0.5), () => window.console.dir(context['jQuery']));

  jqueryWaitFn(0);
}

bool hasFinishedLoading = false;
void jqueryWaitFn(num time ) {
  try {
    if( querySelector("#canvas") != null ) {
      tool = new DrawingTool( (querySelector("#canvas") as CanvasElement) );
      toolInterface = new DrawingToolInterface( tool );
    }
    var site = new SiteApp(tool);
  } catch(e) {
    print(e);
    // not ready yet... try next frame
//    window.requestAnimationFrame(jqueryWaitFn);
  }
}

