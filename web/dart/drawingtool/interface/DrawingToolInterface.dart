part of DrawingToolLib;

class DrawingToolInterface {
  DrawingTool _drawingModule;
  HtmlElement _lastSelectedTool;

  List<String> strokeColors = ["#ffdf34","#FFFFFF", "#00ecfc", "#ef43ff"];
  RangeInputElement _$sideCountSlider = null;
  RangeInputElement _$scaleSlider = null;
  RangeInputElement _$opacitySlider = null;
  RangeInputElement _$lineWidthSlider = null;

  CheckboxInputElement _$mirrorCheckbox;
  CheckboxInputElement _$drawPointsCheckbox;
  HtmlElement _$advancedToggleButton;

  HtmlElement _helperText;

  DrawingToolInterface( this._drawingModule ) {
    _setupOutgoingEvents();
    _setupIncommingEvents();

    _drawingModule.initSettingsAndStart(createSettings());
  }

  /// Setup events that originate from user interface to the drawing module
  void _setupOutgoingEvents() {
    // Toggle drawing mode will call changeAction on _drawingModule
    querySelectorAll('[data-drawingmode]').forEach((HtmlElement el) {
      el.onClick.listen((e) => _changeDrawingMode( el.attributes['data-drawingmode'] ) );
    });

    // Listen for edit actions such as undo and clear
    _helperText = querySelector("#help-flash");
    querySelectorAll('[data-edit-action]').forEach((HtmlElement el) {
      el.onClick.listen((e) => _drawingModule.performEditAction( el.attributes['data-edit-action'] ) );
    });
    _helperText.onClick.listen( (e) => SharedDispatcher.emitter.emit( InterfaceEvent.ON_CONFIRMED, null ) );

    // Mirroring toggle
    _$mirrorCheckbox = ( querySelector("[name=toggle-mirroring]") as CheckboxInputElement );
    _$mirrorCheckbox.parent.onClick.listen((e) => _drawingModule.performEditAction( "setMirrorMode", !_$mirrorCheckbox.checked ) );

    // Draw points
    _$drawPointsCheckbox = ( querySelector("[name=toggle-draw-points]") as CheckboxInputElement );
    _$drawPointsCheckbox.parent.onClick.listen((e) => _drawingModule.performEditAction( "setEditablePoints", !_$drawPointsCheckbox.checked ) );

    // Scale count slider
    _$scaleSlider = ( querySelector("#interface-scale-slider") as RangeInputElement );
    _$scaleSlider.onChange.listen((e) => _drawingModule.performEditAction( "scale", double.parse(_$scaleSlider.value) / 100.0 ) );

    // Side count slider
    _$sideCountSlider = ( querySelector("#interface-sidecount-slider") as RangeInputElement );
    _$sideCountSlider.onChange.listen((e) => _drawingModule.performEditAction('sides', int.parse(_$sideCountSlider.value) ));

    // Opacity slider
    _$opacitySlider = ( querySelector("#interface-opacity-slider") as RangeInputElement );
    _$opacitySlider.onChange.listen((e){
      _drawingModule.performEditAction( "alpha", double.parse( _$opacitySlider.value ) / 100.0 );
    });

    // Opacity slider
    _$lineWidthSlider = ( querySelector("#interface-line-width-slider") as RangeInputElement );
    _$lineWidthSlider.onChange.listen((e){
      _drawingModule.performEditAction( "linewidth", double.parse( _$lineWidthSlider.value ) );
    });

    // Listen for advanced options toggle
    _$advancedToggleButton = querySelector("#advanced-toggle")
    ..onClick.listen( _toggleAdvancedMenus )
    ..onTouchEnd.listen( _toggleAdvancedMenus );

    //interface-color-line-slider
    context.callMethod("jQuery", ['#interface-color-line-slider']).callMethod('spectrum', [new JsObject.jsify({
      'showPalette': true,
      'showPaletteOnly': true,
      'palette'  : strokeColors,
        'change'   : new JsFunction.withThis((InputElement element, dynamic color ) => _drawingModule.performEditAction("lineColor", color) )
    })]);
    context.callMethod("jQuery", ['#interface-color-gradient-start-slider']).callMethod('spectrum', [new JsObject.jsify({
        'change'   : new JsFunction.withThis((InputElement element, dynamic color ) => _drawingModule.performEditAction("gradientStartColor", color) )
    })]);
    context.callMethod("jQuery", ['#interface-color-gradient-end-slider']).callMethod('spectrum', [new JsObject.jsify({
        'change'   : new JsFunction.withThis((InputElement element, dynamic color ) => _drawingModule.performEditAction("gradientEndColor", color) )
    })]);

    // close out on first call
//    new Future.delayed(new Duration(seconds:1), () => _toggleAdvancedMenus(null) );
  }

  ActionSettings createSettings(){
    ActionSettings settings = new ActionSettings();
    settings.isMirrored = _$mirrorCheckbox.checked;
    settings.sides = _$sideCountSlider.valueAsNumber;
    settings.strokeColor = new ColorValue.from(strokeColors[0]);
    settings.fillColor = new ColorValue.from(strokeColors[0]);
    settings.lineWidth = _$lineWidthSlider.valueAsNumber;
    settings.opacity = double.parse( _$opacitySlider.defaultValue ) / 100.0;
    return settings;
  }

  void onSignInDropDownSelected( dynamic thing ) {
    print(thing);
  }

  /// Setup events that originate from the drawingModule and effect the user interface
  void _setupIncommingEvents() {
    SharedDispatcher.emitter.on(DrawingToolEvent.ON_ACTION_CHANGED, onActionChanged );
    SharedDispatcher.emitter.on(DrawingToolEvent.ON_DRAW_POINTS_CHANGED, onDrawPointsChanged );
    SharedDispatcher.emitter.on(DrawingToolEvent.ON_MIRROR_MODE_CHANGED, onMirrorModeChanged );
    SharedDispatcher.emitter.on(DrawingToolEvent.ON_SIDES_CHANGED, onSideCountChanged );
    SharedDispatcher.emitter.on(DrawingToolEvent.ON_SCALE_CHANGED, onScaleChanged );
    SharedDispatcher.emitter.on(DrawingToolEvent.ON_OPACITY_CHANGED, onOpacityChanged );
    SharedDispatcher.emitter.on(DrawingToolEvent.ON_LINEWIDTH_CHANGED, onLineWidthChanged );
    SharedDispatcher.emitter.on(ActionEvent.ON_BECAME_UNCONFIRMED, onActionBecameUnconfirmed );
    SharedDispatcher.emitter.on(ActionEvent.ON_BECAME_CONFIRMABLE, onActionBecameConfirmable );
  }

  // Change the drawing mode and flash some helper text

  void _changeDrawingMode( String actionName ) {
    print("CHANGEME");
    _drawingModule.changeAction(  actionName );
    onActionBecameUnconfirmed( actionName );
  }

  void onActionBecameUnconfirmed( String actionName ) {
    // Fade out
    context['TweenMax'].callMethod("to",[_helperText, 0.15, new JsObject.jsify({
        'alpha' : 0,
        'display': 'none'
    })]);
  }

  void onActionBecameConfirmable( String instructions ) {
    _helperText.text = instructions;
    // Fade in
    context['TweenMax'].callMethod("killDelayedCallsTo",[_helperText]);
    context['TweenMax'].callMethod("fromTo",[_helperText, 0.5, new JsObject.jsify({ 'scale': '1.2', 'alpha' : 0.5, 'display': 'block' }), new JsObject.jsify({ 'scale': '1', 'alpha' : 1.0, 'display': 'block' })]);
  }

  /**
  * Toggles the menus under 'advanced', uses the attribute [data-is-showing] in the _$advancedToggleButton to show/hide
  * Calls TweenMax via JSContext in order to provide animation
  */
  void _toggleAdvancedMenus( e ) {
    var next = _$advancedToggleButton.nextElementSibling;
    bool menusAreCurrentlyShowing = JSON.decode( _$advancedToggleButton.dataset["isShowing"] );
    bool shouldHideMenus = !menusAreCurrentlyShowing;

    _$advancedToggleButton.dataset["isShowing"] = (!menusAreCurrentlyShowing).toString();

    int i = 0;
    while(next != null) {
      context['TweenMax'].callMethod("to",[next, 0.15, new JsObject.jsify({
          "delay" : 0.2 + (-i)*0.02,
          "y": (menusAreCurrentlyShowing) ? "50" : 0,
          "autoAlpha": (menusAreCurrentlyShowing) ? 0 : 1,
          "display" : menusAreCurrentlyShowing ? "none" : "block"
      })]);
      next.style.pointerEvents = menusAreCurrentlyShowing ? "none" : "auto";
      next = next.nextElementSibling;
      i++;
    }

    // Rotate the chevron
    context['TweenMax'].callMethod("to",["#advanced-toggle-chevron", 0.15, new JsObject.jsify({
        "rotation": (menusAreCurrentlyShowing) ? "180" : "0"
    })]);
  }

  /////////////////////////////////////////////////
  ////////////// INTERFACE LISTENERS //////////////
  /////////////////////////////////////////////////
  void onActionChanged( String actionName ) {
    querySelectorAll('[data-drawingmode]').forEach((HtmlElement el) {
      if( el.attributes['data-drawingmode'] == actionName )  el.classes.add('active');
      else el.classes.remove('active');
    });
  }
  
  void onSideCountChanged( int sideCount ) {
    _$sideCountSlider.value = sideCount.toString();
    querySelector("#interface-sidecount-slider-text").text = "Sides: " + sideCount.toString();
  }
  
  void onLineWidthChanged( num lineWidth ) {
    _$lineWidthSlider.value = lineWidth.toStringAsPrecision(2);
    querySelector("#interface-line-width-slider-text").text = "Width: " + (lineWidth*100).toInt().toString();
  }

  void onOpacityChanged( num opacity ) {
    _$opacitySlider.value = (opacity*100).toString();
    querySelector("#interface-opacity-slider-text").text = "Alpha: ." + opacity.toStringAsPrecision(2);
  }
  
  void onMirrorModeChanged( bool mirrorMode ) {
    _$mirrorCheckbox.checked = mirrorMode;
    _$mirrorCheckbox.nextElementSibling.text = "Mirror Mode ";// + (mirrorCheckbox.checked ? "On" : "Off");
  }
  
  void onDrawPointsChanged( bool drawPoints ) {
    _$drawPointsCheckbox.checked = drawPoints;
    _$drawPointsCheckbox.nextElementSibling.text = "Draw Points ";// + (drawPointsCheckbox.checked ? "On" : "Off");
  }

  void onScaleChanged( num scale ) {
    _$scaleSlider.value = (scale*100).toInt().toString();
    _$scaleSlider.nextElementSibling.text = "Zoom " + scale.toStringAsPrecision(2);
  }
}
