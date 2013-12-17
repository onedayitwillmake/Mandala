part of DrawingToolLib;

class DrawingTool {
  int sides = 5;
  CanvasElement _canvas;
  CanvasRenderingContext2D _ctx;

  num _width;
  num _height;
  bool _mirror = true;
  CanvasGradient _bgGradient;

  ListQueue<BaseAction> actionQueue = new ListQueue<BaseAction>();

  DrawingTool(this._canvas) {
    _ctx = _canvas.context2D;
    _width = _canvas.width;
    _height = _canvas.height;

    // SETUP BACKGROUND GRADIENT
    _bgGradient = _ctx.createRadialGradient(_width*0.5, _height*0.5, 0, _width*0.5, _height*0.5, _width*0.5);
    _bgGradient.addColorStop(0, '#383245');
    _bgGradient.addColorStop(1, '#1B1821');

    // Listen for input
    // Down
    _canvas.onMouseDown.listen((e){ _inputDown( e.page ); });
    _canvas.onTouchStart.listen((e){ _inputDown( e.touches[0].page ); });
    // Move
    _canvas.onMouseMove.listen((e){ _inputMove( e.page ); });
    _canvas.onTouchMove.listen((e){ _inputMove( e.touches[0].page ); });
    // Up
    _canvas.onTouchEnd.listen((e){ _inputUp( e.touches[0].page ); });
    _canvas.onMouseUp.listen((e){ _inputUp( e.page); });

//    updateCanvas();
//    BaseAction action = new BaseAction();
//    action.initializeModel()
    actionQueue.add( new RegularStrokeAction() );

    window.requestAnimationFrame(_update);
  }

  void _inputDown( Point pos ) {
    actionQueue.last.inputDown( _ctx, pos );
  }

  void _inputMove( Point pos ) {
//    print("Move {x},{y}");
  }

  void _inputUp( Point pos ) {
//    print("Up {x},{y}");
  }

  void _update( num time ) {
    _ctx.clearRect(0, 0, _width, _height);
    drawBackground();

    // Draw everything twice if mirroring is turned on
    for( int j = 0; j < (_mirror ? 2 : 1); j++) {
      // Call every action once, per side
      for( int i = 0; i < sides; i++) {
        // Reset the transform
        _ctx.setTransform(1, 0, 0, 1, _width*0.5, _height*0.5);
        // Rotate clockwise, so that if i = (sides/2) - we're at 180 degrees
        // add PI*J - meaning 0 on first call, or 180 degrees on second call
        _ctx.rotate(i/sides * PI * 2 + PI*j);

        actionQueue.forEach((BaseAction action){
          action.execute( _ctx, _width, _height );
        });
      }
    }
  }

  void drawBackground() {
    _ctx.clearRect(0, 0, _width, _height);
    _ctx.fillStyle = _bgGradient;
    _ctx.fillRect(0,0,_width,_height);
  }
}
