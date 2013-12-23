part of DrawingToolLib;

class DrawingTool {
  /// Emitted when the current action has changed
  static const String ON_ACTION_CHANGED = "DrawingTool.ON_ACTION_CHANGED";
  /// Emitted when mirror mode has been toggled
  static const String ON_MIRROR_MODE_CHANGED = "DrawingTool.ON_MIRROR_MODE_CHANGED";
  /// Emitted when shouldDrawEditablePoints has been toggled
  static const String ON_DRAW_POINTS_CHANGED = "DrawingTool.ON_DRAW_POINTS_CHANGED";
  /// Emitted when the number of sides is updated
  static const String ON_SIDES_CHANGED = "DrawingTool.ON_SIDES_CHANGED";
  /// Emitted when the number of sides is updated
  static const String ON_SCALE_CHANGED = "DrawingTool.ON_SCALE_CHANGED";
  /// Emitted when the opacity value has been updated
  static const String ON_OPACITY_CHANGED = "DrawingTool.ON_OPACITY_CHANGED";
  /// Emitted when the line-width value has been updated
  static const String ON_LINEWIDTH_CHANGED = "DrawingTool.ON_LINEWIDTH_CHANGED";

  EventEmitter              eventEmitter = new EventEmitter();

  /// Number of sides in we draw (x2 if mirroring is on)
  int                       _sides = 7;

  /// If true, anything drawn on the left side of the canvas will be redraw on the right side
  bool                      _isMirrored = true;

  /// If true - draggable points are drawn for the current tool
  bool                      _shouldDrawEditablePoints = true;

  /// Scale the canvas area by this value, 1.0 is unscaled
  num                       _scale = 1.0;

  /// Canvas element we're drawing to
  CanvasElement             _canvas;

  /// 2D rendering context
  CanvasRenderingContext2D  _ctx;

  /// Reference to background gradient which is redrawn each frame
  CanvasGradient            _bgGradient;
  Svg.RadialGradientElement _bgGradientSvg;

  /// Canvas bounding rect to offset input positions
  Rectangle                 _canvasRect;

  /// Used to offset the touch position if the user has scrolled
  Geom.Point                _winScroll;
  /// Used internally to track RAF
  int                       _rafId = 0;
  /// If true the user's input is down while the mouse is moving
  bool                      _isDragging = false;


  /// List of Actions (for example draw regular stroke, change settings )
  ListQueue<BaseAction> actionQueue = new ListQueue<BaseAction>();


  DrawingTool(this._canvas) {
    _canvasRect = _canvas.getBoundingClientRect();
    _winScroll = new Geom.Point(window.scrollX, window.scrollY);

    _ctx = _canvas.context2D;

    // SETUP BACKGROUND GRADIENT
    _bgGradient = _ctx.createRadialGradient(_canvasRect.width*0.5, _canvasRect.height*0.5, 0, _canvasRect.width*0.5, _canvasRect.height*0.65, _canvasRect.width*0.65);
    _bgGradient.addColorStop(0, '#383245');
    _bgGradient.addColorStop(1, '#1B1821');

    _bgGradientSvg = new Svg.SvgElement.tag("radialGradient");
    _bgGradientSvg.attributes['id'] = "background-gradient";
    var stop = new Svg.StopElement();
    stop.attributes['offset'] = "0%";
    stop.attributes['stop-color'] = "#383245";
    _bgGradientSvg.nodes.add(stop);
    stop = new Svg.StopElement();
    stop.attributes['offset'] = "100%";
    stop.attributes['stop-color'] = "#1B1821";
    _bgGradientSvg.nodes.add(stop);
    
    _setupListeners();

    changeAction( RegularStrokeAction.ACTION_NAME );
    start();
  }

  /// Sets up DOM and window listeners for input, resize, scroll and RAF
  void _setupListeners() {
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
      _winScroll = new Geom.Point(window.scrollX, window.scrollY);
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
  }

  void start(){
    stop();
    _dispatchAllStateEvents();
    _rafId = window.requestAnimationFrame(_update);
  }

  void stop(){
    window.cancelAnimationFrame(_rafId);
    _rafId = 0;
  }

  void _inputDown( Point pos ) {
    _isDragging = true;
    actionQueue.last.inputDown( _ctx, _alignedPoint( pos ), _shouldDrawEditablePoints );
  }

  void _inputMove( Point pos ) {
    actionQueue.last.inputMove( _ctx, _alignedPoint( pos ), _isDragging );
  }

  void _inputUp( Point pos ) {
    _isDragging = false;
    actionQueue.last.inputUp( _ctx, _alignedPoint( pos ) );
  }

  // Adjust the point position so that 0,0 is the topleft 
  Geom.Point _alignedPoint( Point pos ) {
    num x = (pos.x - _canvasRect.left) - (_canvasRect.width*0.5);
    num y = ( (pos.y - _canvasRect.top) - (_canvasRect.height*0.5) );
    return new Geom.Point(x/_scale,y/_scale);
  }

  void _update( num time ) {
    _ctx.canvas.width = _ctx.canvas.width;
    
    _drawBackground();
    
    _ctx.globalCompositeOperation = 'screen';

    // Draw everything twice if mirroring is turned on
    for( int j = 0; j < (_isMirrored ? 2 : 1); j++) {
      int xOffset = j == 0 ? 1 : -1;

      // Call every action once, per side
      for( int i = 0; i < _sides; i++) {
        // Reset the transform
        _ctx.setTransform(xOffset*_scale, 0, 0, _scale, _canvasRect.width*0.5, _canvasRect.height*0.5);
        // Rotate clockwise, so that if i = (sides/2) - we're at 180 degrees
        // add PI*J - meaning 0 on first call, or 180 degrees on second call
        _ctx.rotate(i/_sides * PI * 2);

        actionQueue.forEach((BaseAction action){
          action.execute( _ctx, _canvasRect.width, _canvasRect.height );
        });

        if( xOffset == 1 && i == 0 ) {
          actionQueue.last.activeDraw( _ctx, _canvasRect.width, _canvasRect.height, _shouldDrawEditablePoints );
        }
      }
    }

    // Draw the arc enveloping the image
    _ctx.beginPath();
    _ctx.lineWidth = 1;
    _ctx.setStrokeColorRgb(255, 255, 255, 0.75);
    _ctx.arc(0, 0, _canvasRect.width*0.46, 0, PI * 2, false);
    _ctx.stroke();
    _ctx.closePath();

    _rafId = window.requestAnimationFrame(_update);
  }
  
  /// Changes the current action by appending a new instance to the actionQueue
  bool changeAction( String actionName ) {
    
    // We're already in that mode
//    if( actionQueue.isNotEmpty && actionQueue.last.name == actionName ) {
//      return false;
//    }

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
      case SmoothFillAction.ACTION_NAME:
        nextAction = new SmoothFillAction();
      break;
      case RegularFillAction.ACTION_NAME:
        nextAction = new RegularFillAction();
      break;
    }

    // Set the newAction's opacity to the current action's opacity
    if( actionQueue.isNotEmpty ) {
      nextAction.settings.opacity = actionQueue.last.settings.opacity;
    }
    
    actionQueue.add( nextAction );
    
    _dispatchActionChangedEvent();
    
    return true;
  }

  void performEditAction( String actionName, [dynamic value] ) {
   
    switch( actionName ) {
      case "undo":
        _performUndo();
      break;
      case "alpha":
        actionQueue.last.settings.opacity = value;
        _dispatchOpacityChangedEvent();
      break;
      case "sides":
        _sides = value;
        _dispatchOnSidesChangedEvent();
      break;
      case "scale":
        _scale = value;
        _dispatchScaleChangedEvent();
      break;
      case "setEditablePoints":
        _shouldDrawEditablePoints = value;
        _dispatchOnDrawPointsChanged();
      break;
      case "setMirrorMode":
        _isMirrored = value;
        _dispatchMirrorModeChangedEvent();
        break;
      case "linewidth":
        actionQueue.last.settings.lineWidth = value;
        _dispatchLineWidthChangedEvent();
        break;
    }
    
    print(actionName);
    
  }

  /**
  * Performs an undo operation, will pop the last state if there are not points in that state
  */
  void _performUndo() {
    // Current action has no points and user wants to undo - remove that action
    if( actionQueue.last.points.length == 0 ) {
      if( actionQueue.length == 1 ) return; // dont remove the last action

      actionQueue.removeLast();
      _dispatchActionChangedEvent();
    }

    // Nothing to undo again!
    if( actionQueue.length == 0 ) return;

    actionQueue.last.undo( _ctx );
  }

  void _drawBackground() {
    _ctx.fillStyle = _bgGradient;
    _fillRoundedRect(_ctx, 0,0,_canvasRect.width,_canvasRect.height, 8);
  }

  void _fillRoundedRect( dynamic ctx, x, y, w, h, r ) {
    ctx.beginPath();
    ctx.moveTo(x+r, y);
    ctx.lineTo(x+w-r, y);
    ctx.quadraticCurveTo(x+w, y, x+w, y+r);
    ctx.lineTo(x+w, y+h-r);
    ctx.quadraticCurveTo(x+w, y+h, x+w-r, y+h);
    ctx.lineTo(x+r, y+h);
    ctx.quadraticCurveTo(x, y+h, x, y+h-r);
    ctx.lineTo(x, y+r);
    ctx.quadraticCurveTo(x, y, x+r, y);
    ctx.fill();
    ctx.closePath();
  }
  
  //// -------- SVG Save
  Svg.SvgElement saveSvg( ) {
    
    SvgRenderer svgCtx = new SvgRenderer(_canvasRect.width.toInt(), _canvasRect.height.toInt() );
    
    svgCtx.defs.nodes.add( _bgGradientSvg );

    svgCtx.groupStart();
    svgCtx.fillStyle = "url(#${_bgGradientSvg.id})";
      _fillRoundedRect( svgCtx, 0,0,_canvasRect.width,_canvasRect.height, 8);
    svgCtx.groupEnd();
    
    // Draw everything twice if mirroring is turned on
    for( int j = 0; j < (_isMirrored ? 2 : 1); j++) {
      int xOffset = j == 0 ? 1 : -1;

      // Call every action once, per side
      for( int i = 0; i < _sides; i++) {
        svgCtx.groupStart();
        
        // Reset the transform
        svgCtx.setTransform(xOffset*_scale, 0, 0, _scale, _canvasRect.width*0.5, _canvasRect.height*0.5);
        // Rotate clockwise, so that if i = (sides/2) - we're at 180 degrees
        // add PI*J - meaning 0 on first call, or 180 degrees on second call
        svgCtx.rotate(i/_sides * PI * 2);

        actionQueue.forEach((BaseAction action){
          action.executeForSvg( svgCtx, _canvasRect.width, _canvasRect.height );
        });
        
        svgCtx.groupEnd();
      }
    }

    // Arc around
    svgCtx.groupStart();
    svgCtx.lineWidth = 2;
    svgCtx.beginPath();    
    svgCtx.setStrokeColorRgb(255, 255, 255, 0.75);
    svgCtx.arc(width*0.5, height*0.5, _canvasRect.width*0.46, 0, PI*2, false);
    svgCtx.stroke();
    svgCtx.closePath();
    svgCtx.groupEnd();

    return svgCtx.svg;
  }

  /////////////////////////////////////////////////
  /////////////// EVENT DISPATCHING ///////////////
  /////////////////////////////////////////////////
  void _dispatchAllStateEvents() {
    _dispatchActionChangedEvent();
    _dispatchMirrorModeChangedEvent();
    _dispatchOnDrawPointsChanged();
    _dispatchOnSidesChangedEvent();
    _dispatchScaleChangedEvent();
    _dispatchOpacityChangedEvent();
    _dispatchLineWidthChangedEvent();
  }
  void _dispatchActionChangedEvent() {
    eventEmitter.emit( DrawingTool.ON_ACTION_CHANGED, actionQueue.last.name );
    _dispatchOpacityChangedEvent();
  }
  void _dispatchMirrorModeChangedEvent( ) => eventEmitter.emit( DrawingTool.ON_MIRROR_MODE_CHANGED, _isMirrored );
  void _dispatchOnDrawPointsChanged() => eventEmitter.emit( DrawingTool.ON_DRAW_POINTS_CHANGED, _shouldDrawEditablePoints );
  void _dispatchOnSidesChangedEvent() => eventEmitter.emit( DrawingTool.ON_SIDES_CHANGED, _sides );
  void _dispatchScaleChangedEvent() => eventEmitter.emit( DrawingTool.ON_SCALE_CHANGED, _scale );
  void _dispatchOpacityChangedEvent() => eventEmitter.emit( DrawingTool.ON_OPACITY_CHANGED, actionQueue.last.settings.opacity );
  void _dispatchLineWidthChangedEvent() => eventEmitter.emit( DrawingTool.ON_LINEWIDTH_CHANGED, actionQueue.last.settings.lineWidth );

  /////////////////////////////////////////////////
  ////////////////// PROPERTIES ///////////////////
  /////////////////////////////////////////////////
  num get width => _canvasRect.width;
  num get height => _canvasRect.height;
}
