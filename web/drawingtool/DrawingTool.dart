part of DrawingToolLib;

class DrawingTool {
  /// Number of sides in we draw (x2 if mirroring is on)
  int                       sides = 5;

  /// If true, anything drawn on the left side of the canvas will be redraw on the right side
  bool                      isMirrored = true;

  /// Canvas element we're drawing to
  CanvasElement             _canvas;

  /// 2D rendering context
  CanvasRenderingContext2D  _ctx;

  /// Reference to background gradient which is redrawn each frame
  CanvasGradient            _bgGradient;

  /// Canvas bounding rect to offset input positions
  Rectangle                 _canvasRect;

  /// Used to offset the touch position if the user has scrolled
  Point                     _winScroll;
  /// Used internally to track RAF
  int                       _rafId = 0;

  /// List of Actions (for example draw regular stroke, change settings )
  ListQueue<BaseAction> actionQueue = new ListQueue<BaseAction>();

  DrawingTool(this._canvas) {
    _canvasRect = _canvas.getBoundingClientRect();
    _winScroll = new Point(window.scrollX, window.scrollY);

    _ctx = _canvas.context2D;

    // SETUP BACKGROUND GRADIENT
    _bgGradient = _ctx.createRadialGradient(_canvasRect.width*0.5, _canvasRect.height*0.5, 0, _canvasRect.width*0.5, _canvasRect.height*0.5, _canvasRect.width*0.5);
    _bgGradient.addColorStop(0, '#383245');
    _bgGradient.addColorStop(1, '#1B1821');

    actionQueue.add( new RegularStrokeAction() );

    setupListeners();
    start();
  }

  /// Sets up DOM and window listeners for input, resize, scroll and RAF
  void setupListeners() {
    // Listen for canvas input
      // Down
    _canvas.onMouseDown.listen((e){ _inputDown( e.page ); });
    _canvas.onTouchStart.listen((e){ _inputDown( e.touches[0].page ); });
      // Move
    _canvas.onMouseMove.listen((e){ _inputMove( e.page ); });
    _canvas.onTouchMove.listen((e){ _inputMove( e.touches[0].page ); });
      // Up
    _canvas.onMouseUp.listen((e){ _inputUp( e.page); });
    _canvas.onTouchEnd.listen((e){ _inputUp( e.touches[0].page ); });

    // Window resize
    window.onResize.listen((e) {
      _canvasRect = _canvas.getBoundingClientRect();
    });
    // Window scroll
    window.onScroll.listen((e) {
      _winScroll = new Point(window.scrollX, window.scrollY);
    });
    // Lost focus
    window.onBlur.listen((e){
      stop();
    });
    // Lost focus
    window.onFocus.listen((e){
      start();
    });
  }

  void start(){
    stop();
    _rafId = window.requestAnimationFrame(_update);
  }

  void stop(){
    window.cancelAnimationFrame(_rafId);
    _rafId = 0;
  }

  void _inputDown( Point pos ) {
    actionQueue.last.inputDown( _ctx, alignedPoint( pos ) );
  }

  void _inputMove( Point pos ) {
    actionQueue.last.inputMove( _ctx, alignedPoint( pos ) );
  }

  void _inputUp( Point pos ) {
    actionQueue.last.inputUp( _ctx, alignedPoint( pos ) );
  }

  void alignedPoint( Point pos ) {
    int x = (pos.x - _canvasRect.left - _winScroll.x) - (_canvasRect.width*0.5);
    int y = (pos.y - _canvasRect.top - _winScroll.y) - (_canvasRect.height*0.5);
    return new Point(x,y);
  }

  void _update( num time ) {
    drawBackground();

    // Draw everything twice if mirroring is turned on
    for( int j = 0; j < (isMirrored ? 2 : 1); j++) {
      // Call every action once, per side
      for( int i = 0; i < sides; i++) {
        // Reset the transform
        _ctx.setTransform(1, 0, 0, 1, _canvasRect.width*0.5, _canvasRect.height*0.5);
        // Rotate clockwise, so that if i = (sides/2) - we're at 180 degrees
        // add PI*J - meaning 0 on first call, or 180 degrees on second call
        _ctx.rotate(i/sides * PI * 2 + PI*j);

        actionQueue.forEach((BaseAction action){
          action.execute( _ctx, _canvasRect.width, _canvasRect.height );
        });
      }
    }

    _rafId = window.requestAnimationFrame(_update);
  }

  void drawBackground() {
    _ctx.canvas.width = _ctx.canvas.width;
    _ctx.fillStyle = _bgGradient;
    _ctx.fillRect(0,0,_canvasRect.width,_canvasRect.height);
  }
}
