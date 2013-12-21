part of DrawingToolLib;

class DrawingTool {
  /// Number of sides in we draw (x2 if mirroring is on)
  int                       sides = 1;

  /// If true, anything drawn on the left side of the canvas will be redraw on the right side
  bool                      isMirrored = false;

  /// Canvas element we're drawing to
  CanvasElement             _canvas;

  /// 2D rendering context
  CanvasRenderingContext2D  _ctx;

  /// Reference to background gradient which is redrawn each frame
  CanvasGradient            _bgGradient;

  /// Canvas bounding rect to offset input positions
  Rectangle                 _canvasRect;

  /// Used to offset the touch position if the user has scrolled
  Point<num>                 _winScroll;
  /// Used internally to track RAF
  int                       _rafId = 0;
  /// If true the user's input is down while the mouse is moving
  bool                      _isDragging = false;

  /// List of Actions (for example draw regular stroke, change settings )
  ListQueue<BaseAction> actionQueue = new ListQueue<BaseAction>();

  
  DrawingTool(this._canvas) {
    _canvasRect = _canvas.getBoundingClientRect();
    _winScroll = new Point(window.scrollX, window.scrollY);

    _ctx = _canvas.context2D;

    // SETUP BACKGROUND GRADIENT
    _bgGradient = _ctx.createRadialGradient(_canvasRect.width*0.5, _canvasRect.height*0.5, 0, _canvasRect.width*0.5, _canvasRect.height*0.65, _canvasRect.width*0.65);
    _bgGradient.addColorStop(0, '#383245');
    _bgGradient.addColorStop(1, '#1B1821');

    actionQueue.add( new SmoothStrokeAction() );

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
    // Gained focus
    window.onFocus.listen((e){
      start();
    });
    // Keyboard
    window.onKeyDown.listen( (e) => actionQueue.last.keyPressed( _ctx, e) );
    
//    setupStageXL();
  }
//  StageXL.Bitmap backgroundBitmap;
//  StageXL.BitmapData bitmapData;
//  void setupStageXL() {
//    var stage = new StageXL.Stage('stage', querySelector('#stage'));
//    var renderLoop = new StageXL.RenderLoop();
//    renderLoop.addStage(stage);
//    var juggler = renderLoop.juggler;
//    
//    //  BitmapData(int width, int height, [bool transparent = true, int fillColor = 0xFFFFFFFF, pixelRatio = 1.0]) {
//    bitmapData = new StageXL.BitmapData(_canvasRect.width.toInt(),_canvasRect.height.toInt(), false, 0);   
//    backgroundBitmap = new StageXL.Bitmap(bitmapData);
//    backgroundBitmap.filters = [ new StageXL.BlurFilter(2,2) ];
//    backgroundBitmap.applyCache(0,0, backgroundBitmap.width.toInt(), backgroundBitmap.height.toInt());
//    stage.addChild(backgroundBitmap);
//    //new BlurFilter(20, 20)
//  }

  void start(){
    stop();
    _rafId = window.requestAnimationFrame(_update);
  }

  void stop(){
    window.cancelAnimationFrame(_rafId);
    _rafId = 0;
  }

  void _inputDown( Point pos ) {
    _isDragging = true;
    actionQueue.last.inputDown( _ctx, alignedPoint( pos ) );
  }

  void _inputMove( Point pos ) {
    actionQueue.last.inputMove( _ctx, alignedPoint( pos ), _isDragging );
  }

  void _inputUp( Point pos ) {
    _isDragging = false;
    actionQueue.last.inputUp( _ctx, alignedPoint( pos ) );
  }

  Point alignedPoint( Point pos ) {
    int x = (pos.x - _canvasRect.left - _winScroll.x) - (_canvasRect.width*0.5);
    int y = (pos.y - _canvasRect.top - _winScroll.y) - (_canvasRect.height*0.5);
    return new Point(x,y);
  }

  void _update( num time ) {
   drawBackground();
    _ctx.globalCompositeOperation = 'screen';

    // Draw everything twice if mirroring is turned on
    for( int j = 0; j < (isMirrored ? 2 : 1); j++) {
      int xOffset = j == 0 ? 1 : -1;

      // Call every action once, per side
      for( int i = 0; i < sides; i++) {
        // Reset the transform
        _ctx.setTransform(xOffset, 0, 0, 1, _canvasRect.width*0.5, _canvasRect.height*0.5);
        // Rotate clockwise, so that if i = (sides/2) - we're at 180 degrees
        // add PI*J - meaning 0 on first call, or 180 degrees on second call
        _ctx.rotate(i/sides * PI * 2);

        actionQueue.forEach((BaseAction action){
          action.execute( _ctx, _canvasRect.width, _canvasRect.height );
        });

        actionQueue.last.activeDraw( _ctx, _canvasRect.width, _canvasRect.height );
      }
    }

    // Draw the arc enveloping the image
    _ctx.beginPath();
    _ctx.lineWidth = 1;
    _ctx.strokeStyle = "rgba(255,255,255,0.75)";
    _ctx.arc(0, 0, _canvasRect.width*0.46, 0, PI * 2, false);
    _ctx.stroke();
    _ctx.closePath();

//    bitmapData.putImageData(_ctx.getImageData(0, 0, _canvasRect.width, _canvasRect.height), 0, 0);
//    backgroundBitmap.refreshCache();
    _rafId = window.requestAnimationFrame(_update);
  }

  bool changeAction( String actionName ) {
    print("CurrentActionName: ${actionQueue.last.name}");
    // We're already in that mode
    if( actionQueue.last.name == actionName ) {
      return false;
    }

    BaseAction nextAction = null;
    switch( actionName ) {
      case RegularStrokeAction.ACTION_NAME:
        nextAction = new RegularStrokeAction();
      break;
      case SmoothStrokeAction.ACTION_NAME:
        nextAction = new SmoothStrokeAction();
      break;
      case PolygonalFillAction.ACTION_NAME:
        nextAction = new PolygonalFillAction();
      break;
      case PolygonalStrokeAction.ACTION_NAME:
        nextAction = new PolygonalStrokeAction();
      break;
    }

    // TODO: Call exit on current action?
    if( nextAction == null ) return false;

    actionQueue.add( nextAction );
    return true;
  }
  
  void performEditAction( String actionName, [dynamic value] ) {
    switch( actionName ) {
      case "undo":
        performUndo();
      break;
      case "alpha":
        actionQueue.last.settings.opacity = value;
      break;
    }
  }

  void performUndo() {

    // Current action has no points and user wants to undo - remove that action
    if( actionQueue.last.points.length == 0 ) {
      if( actionQueue.length == 1 ) return; // dont remove the last action

        actionQueue.removeLast();
    }
    
    // Nothing to undo again!
    if( actionQueue.length == 0 ) return;
    
    actionQueue.last.undo( _ctx );
  }

  void drawBackground() {
    _ctx.canvas.width = _ctx.canvas.width;
    _ctx.fillStyle = _bgGradient;
    fillRoundedRect(0,0,_canvasRect.width,_canvasRect.height, 10);
  }

  void fillRoundedRect( x, y, w, h, r ) {
    _ctx.beginPath();
    _ctx.moveTo(x+r, y);
    _ctx.lineTo(x+w-r, y);
    _ctx.quadraticCurveTo(x+w, y, x+w, y+r);
    _ctx.lineTo(x+w, y+h-r);
    _ctx.quadraticCurveTo(x+w, y+h, x+w-r, y+h);
    _ctx.lineTo(x+r, y+h);
    _ctx.quadraticCurveTo(x, y+h, x, y+h-r);
    _ctx.lineTo(x, y+r);
    _ctx.quadraticCurveTo(x, y, x+r, y);
    _ctx.fill();
    _ctx.closePath();
  }
}
