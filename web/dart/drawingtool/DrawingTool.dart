part of DrawingToolLib;

class DrawingTool {
  String                    mandalaId;
  /// Number of sides in we draw (x2 if mirroring is on)
  int                       _sides = 12;

  /// If true, anything drawn on the left side of the canvas will be redraw on the right side
  bool                      _isMirrored = true;

  /// If true - draggable points are drawn for the current tool
  bool                      _allowEditingPoints = true;

  /// Scale the canvas area by this value, 1.0 is unscaled
  num                       _scale = 1.0;

  /// If true the user's input is down while the mouse is moving
  bool                      _isDragging = false;

  /// Glow amount
  int                       _blurAmount = 10;
  /// Glow opacity
  num                       _blurOpacity = 0.5;

  /// Canvas element we're drawing to
  CanvasElement             _canvas;

  /// 2D rendering context
  CanvasRenderingContext2D  _ctx;

  CanvasElement             _offscreenBuffer;

  /// Reference to background gradient which is redrawn each frame
  CanvasGradient            _bgGradient;
  Svg.RadialGradientElement _bgGradientSvg;
  String                    _gradientStart = "#383245";
  String                    _gradientEnd = "#1B1821";

  ColorValue                _arcColor = new ColorValue.fromRGB(255,255,255);

  /// Canvas bounding rect to offset input positions
  Rectangle                 _canvasRect;

  /// Used to offset the touch position if the user has scrolled
  Geom.Point                _winScroll;

  /// Used internally to track RAF
  int                       _rafId = 0;


  /// List of Actions (for example draw regular stroke, change settings )
  ListQueue<BaseAction> actionQueue = new ListQueue<BaseAction>();


  DrawingTool(this._canvas) {
    _canvasRect = _canvas.getBoundingClientRect();
    _winScroll = new Geom.Point(window.scrollX, window.scrollY);

    _ctx = _canvas.context2D;
    _offscreenBuffer = new CanvasElement(width:_canvas.width, height:_canvas.height);

    _setupBackgroundGradients();
    _setupListeners();

    changeAction( RegularStrokeAction.ACTION_NAME, true );
    start();
  }

  // Creates the background Canvas / SVG gradients used as a backdrop on the drawing
  void _setupBackgroundGradients() {
    var colors = [this._gradientStart, this._gradientEnd];

    _bgGradient = _ctx.createRadialGradient(_canvasRect.width*0.5, _canvasRect.height*0.5, 0, _canvasRect.width*0.5, _canvasRect.height*0.5, _canvasRect.width*0.65);
    _bgGradient.addColorStop(0, colors[0] );
    _bgGradient.addColorStop(1, colors[1] );

    _bgGradientSvg = new Svg.SvgElement.tag("radialGradient");
    _bgGradientSvg.attributes['id'] = "background-gradient";
    var stop = new Svg.StopElement();
    stop.attributes['offset'] = "0%";
    stop.attributes['stop-color'] = colors[0];
    _bgGradientSvg.nodes.add(stop);
    stop = new Svg.StopElement();
    stop.attributes['offset'] = "100%";
    stop.attributes['stop-color'] = colors[1];
    _bgGradientSvg.nodes.add(stop);
  }

  /// Sets up DOM and window listeners for input, resize, scroll and RAF
  void _setupListeners() {
    // Listen for canvas input
      // Down
    _canvas.onMouseDown.listen((e){ e.preventDefault(); _inputDown( e.page ); });
    _canvas.onTouchStart.listen((e){ e.preventDefault(); _inputDown( e.touches[0].page ); });
      // Move
    _canvas.onMouseMove.listen((e){ e.preventDefault(); _inputMove( e.page ); });
    _canvas.onTouchMove.listen((e){ e.preventDefault(); _inputMove( e.touches[0].page ); });
      // Up
    _canvas.onMouseUp.listen((e){ e.preventDefault(); _inputUp( e.page); });
    _canvas.onTouchEnd.listen((e){ e.preventDefault(); _inputUp( e.touches[0].page ); });

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
    window.onKeyDown.listen( (e) => actionQueue.last.keyPressed(e) );

    //
    SharedDispatcher.emitter.on( ActionEvent.ON_DRAWING_INTERACTION_FINISHED, onActionComplete );
    SharedDispatcher.emitter.on( InterfaceEvent.ON_CONFIRMED, onConfirmed );
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
    actionQueue.last.inputDown( _alignedPoint( pos ), _allowEditingPoints );
  }

  void _inputMove( Point pos ) {
    actionQueue.last.inputMove( _alignedPoint( pos ), _isDragging );
  }

  void _inputUp( Point pos ) {
    _isDragging = false;
    actionQueue.last.inputUp(  _alignedPoint( pos ) );
  }

  /// Returns a new [Geom.Point] such that (0,0) is the TL of the canvas, taking the element's offsets into account
  Geom.Point _alignedPoint( Point pos ) {
    num x = (pos.x - _canvasRect.left) - (_canvasRect.width*0.5);
    num y = ( (pos.y - _canvasRect.top) - (_canvasRect.height*0.5) );
    return new Geom.Point(x/_scale,y/_scale);
  }

  /// Updates the current active tool
  void _update( num time, [bool raf = true] ) {
    // Clear the area
    _ctx.setTransform(1, 0, 0, 1, 0, 0);
    _ctx.clearRect(0,0,_canvasRect.width, _canvasRect.height);
    
    // turn off blending/shadow and draw the offscreen buffer
    _ctx.globalCompositeOperation = 'source-over';
    _ctx.setTransform(1, 0, 0, 1, 0, 0);
    _ctx.shadowBlur = 0;
    _ctx.shadowColor = 'rgba(0, 0, 0, 0)';
    _ctx.drawImage(_offscreenBuffer, 0, 0);
    
    // Renable blending / shadow
    _ctx.globalCompositeOperation = 'screen';
//    _ctx.shadowBlur = _blurAmount;
//    _ctx.shadowColor = 'rgba(255, 255, 255, ${_blurOpacity.toStringAsPrecision(2)} )';


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
        
        actionQueue.last.execute( _ctx, _canvasRect.width, _canvasRect.height );
        // First draw, and not the mirrored version
        if( xOffset == 1 && i == 0 ) {
          actionQueue.last.activeDraw( _ctx, _canvasRect.width, _canvasRect.height, _allowEditingPoints );
        }
      }
    }

    if( raf ) _rafId = window.requestAnimationFrame(_update);
  }
  
  void _updateOffscreenBuffer(){
    print("_updateOffscreenBuffer");
    CanvasRenderingContext2D hiddenCtx  = _offscreenBuffer.context2D;
    hiddenCtx.setTransform(1, 0, 0, 1, 0, 0);
    hiddenCtx.clearRect(0,0,_canvasRect.width, _canvasRect.height);

    hiddenCtx.shadowBlur = 0;
    hiddenCtx.shadowColor = 'rgba(0, 0, 0, 0)';
    hiddenCtx.setTransform(1, 0, 0, 1, 0, 0);
    _drawBackground( hiddenCtx );
    hiddenCtx.shadowBlur = _blurAmount;
    hiddenCtx.shadowColor = 'rgba(255, 255, 255, ${_blurOpacity.toStringAsPrecision(2)} )';
    hiddenCtx.globalCompositeOperation = 'screen';

    // Draw everything twice if mirroring is turned on
    for( int j = 0; j < (_isMirrored ? 2 : 1); j++) {
      int xOffset = j == 0 ? 1 : -1;

      // Call every action once, per side
      for( int i = 0; i < _sides; i++) {
        // Reset the transform
        hiddenCtx.setTransform(xOffset*_scale, 0, 0, _scale, _canvasRect.width*0.5, _canvasRect.height*0.5);
        // Rotate clockwise, so that if i = (sides/2) - we're at 180 degrees
        // add PI*J - meaning 0 on first call, or 180 degrees on second call
        hiddenCtx.rotate(i/_sides * PI * 2);

        actionQueue.forEach((BaseAction action){
          if( action == actionQueue.last ) return;

          action.execute( hiddenCtx, _canvasRect.width, _canvasRect.height );
        });
      }
    }

    // Draw the arc enveloping the image
    hiddenCtx.beginPath();
    hiddenCtx.lineWidth = 1;
    hiddenCtx.setStrokeColorRgb(_arcColor.r, _arcColor.g, _arcColor.b, 0.75);
    hiddenCtx.arc(0, 0, _canvasRect.width*0.46, 0, PI * 2, false);
    hiddenCtx.stroke();
    hiddenCtx.closePath();
  }
  
  /// Changes the current action by appending a new instance to the actionQueue
  bool changeAction( String actionName,[bool dispatchEvent = true] ) {
    
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
      nextAction.settings.strokeColor.copyFrom( actionQueue.last.settings.strokeColor );
      nextAction.settings.fillColor.copyFrom( actionQueue.last.settings.fillColor );
    }

    actionQueue.add( nextAction );
    _updateOffscreenBuffer();

    if( dispatchEvent )
      _dispatchActionChangedEvent();

    return true;
  }



  void performEditAction( String actionName, [dynamic value] ) {
    switch( actionName ) {
      case "undo":
        _performUndo();
      break;
      case "clear":
        _performClear();
        break;
      case "alpha":
        actionQueue.last.settings.opacity = value;
        // If the topmost action has no points - the user probably means to change the action of the line they just drew
        if( actionQueue.last.points.length == 0 && actionQueue.length >= 2 ) {
          actionQueue.elementAt( actionQueue.length - 2 ).settings.opacity = value;
        }
        _dispatchOpacityChangedEvent();
      break;
      case "lineColor":
        _changeLineColor( (value as JsObject).toString() );
        break;
      case "gradientStartColor":
//        this._gradientStart = (value as JsObject).toString();
//        _setupBackgroundGradients();
//        _updateOffscreenBuffer();
        break;
      case "gradientEndColor":
//        this._gradientEnd = (value as JsObject).toString();
//        _setupBackgroundGradients();
//        _updateOffscreenBuffer();
        break;
      case "sides":
        _sides = value;
        _updateOffscreenBuffer();
        _dispatchOnSidesChangedEvent();
      break;
      case "scale":
        _scale = value;
        _updateOffscreenBuffer();
        _dispatchScaleChangedEvent();
      break;
      case "setEditablePoints":
        _allowEditingPoints = value;
        _dispatchOnDrawPointsChanged();
      break;
      case "setMirrorMode":
        _isMirrored = value;
        _updateOffscreenBuffer();
        _dispatchMirrorModeChangedEvent();
        break;
      case "linewidth":
        actionQueue.last.settings.lineWidth = value;
        _dispatchLineWidthChangedEvent();
        break;
    }
//    print("No action for ${actionName}");
  }

  /// Action is done, create a copy of it and update the offscreen buffer
  void onActionComplete( BaseAction action ) {
    changeAction( action.name, false );
  }

  /// Called when the confirm button in the interface is clicked
  void onConfirmed( dynamic noop ) {
    actionQueue.last.onConfirmed();
  }

  /// Modifies the line color used for drawing
  void _changeLineColor( value ) {
    // Have the first one parse it
    actionQueue.last.settings.fillColor.parseRgb( value );
    actionQueue.last.settings.strokeColor.parseRgb( value );

    // Copy it to all the othe ones
    actionQueue.forEach((BaseAction action){
      action.settings.fillColor.copyFrom( actionQueue.last.settings.fillColor );
      action.settings.strokeColor.copyFrom( actionQueue.last.settings.strokeColor );
    });

    _arcColor.copyFrom( actionQueue.last.settings.fillColor );
    _arcColor *= 2;
    _updateOffscreenBuffer();
  }

  /// Performs an undo operation, will pop the last state if there are not points in that state
  void _performUndo() {
    // Except for the backmost action, remove all actions which have no points
    while( actionQueue.length > 1 && actionQueue.last.points.length == 0 ) {
      actionQueue.removeLast();
    }

    actionQueue.last.undo( );

    _updateOffscreenBuffer();
    _dispatchActionChangedEvent();
  }

  /// Wipes the entire drawing canvas
  void _performClear() {
    var lastActionName = actionQueue.last.name;
    actionQueue.clear();
    changeAction( lastActionName, true );
  }

  /// Draws the background gradient
  void _drawBackground( dynamic ctx ) {
    ctx.fillStyle = _bgGradient;
//    int x = _canvasRect.width - ( _canvasRect.width * (_scale / 1.0) );
//    int y = _canvasRect.height - ( _canvasRect.height * (_scale / 1.0) );
//    _fillRoundedRect(ctx, x, y, _canvasRect.width*_scale,_canvasRect.height*_scale, 4);
    _fillRoundedRect(ctx, 0,0, _canvasRect.width,_canvasRect.height, 4);

  }

  /// Draws a rounded rectangle with [x],[y],[w],[h] extents
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
  
  /// Creates an SVG Representation of the mandala
  Svg.SvgElement saveSvg( ) {
    bool oldAllowEditingPoints = _allowEditingPoints;
    _allowEditingPoints = false;
    num oldScale = _scale;
    _scale = 1.0;
    
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
    svgCtx.setStrokeColorRgb(_arcColor.r, _arcColor.g, _arcColor.b, 0.75);
    svgCtx.arc(width*0.5, height*0.5, _canvasRect.width*0.46, 0, PI*2, false);
    svgCtx.stroke();
    svgCtx.closePath();
    svgCtx.groupEnd();

    _allowEditingPoints = oldAllowEditingPoints;
    performEditAction("scale", oldScale);
    return svgCtx.svg;
  }

  /// Returns the canvas as an image
  String getDataUrl() {
    // Disable guide points and redraw
    bool oldAllowEditingPoints = _allowEditingPoints;
    _allowEditingPoints = false;
    num oldScale = _scale;
    _scale = 1.0;

    _updateOffscreenBuffer();
    _update( 0, false );
    String imageData = _canvas.toDataUrl();

    _allowEditingPoints = oldAllowEditingPoints;
    performEditAction("scale", oldScale);
    return imageData;
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
    SharedDispatcher.emitter.emit( DrawingToolEvent.ON_ACTION_CHANGED, actionQueue.last.name );
    _dispatchOpacityChangedEvent();
  }
  void _dispatchMirrorModeChangedEvent( ) => SharedDispatcher.emitter.emit( DrawingToolEvent.ON_MIRROR_MODE_CHANGED, _isMirrored );
  void _dispatchOnDrawPointsChanged() => SharedDispatcher.emitter.emit( DrawingToolEvent.ON_DRAW_POINTS_CHANGED, _allowEditingPoints );
  void _dispatchOnSidesChangedEvent() => SharedDispatcher.emitter.emit( DrawingToolEvent.ON_SIDES_CHANGED, _sides );
  void _dispatchScaleChangedEvent() => SharedDispatcher.emitter.emit( DrawingToolEvent.ON_SCALE_CHANGED, _scale );
  void _dispatchOpacityChangedEvent() => SharedDispatcher.emitter.emit( DrawingToolEvent.ON_OPACITY_CHANGED, actionQueue.last.settings.opacity );
  void _dispatchLineWidthChangedEvent() => SharedDispatcher.emitter.emit( DrawingToolEvent.ON_LINEWIDTH_CHANGED, actionQueue.last.settings.lineWidth );

  /////////////////////////////////////////////////
  ////////////////// PROPERTIES ///////////////////
  /////////////////////////////////////////////////
  num get width => _canvasRect.width;
  num get height => _canvasRect.height;
}
