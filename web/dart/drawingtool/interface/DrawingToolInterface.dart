part of DrawingToolLib;

class DrawingToolInterface {
  DrawingTool _drawingModule;
  HtmlElement _lastSelectedTool;

  RangeInputElement _$sideCountSlider = null;
  RangeInputElement _$scaleSlider = null;
  RangeInputElement _$opacitySlider = null;
  
  CheckboxInputElement _$mirrorCheckbox;
  CheckboxInputElement _$drawPointsCheckbox;

  DrawingToolInterface( this._drawingModule ) {
    _setupOutgoingEvents();
    _setupIncommingEvents();
    _drawingModule.start();
  }
  
  /// Setup events that originate from user interface to the drawing module
  void _setupOutgoingEvents() {
    // Toggle drawing mode will call changeAction on _drawingModule
    querySelectorAll('[data-drawingmode]').forEach((HtmlElement el) {
      el.onClick.listen((e) => _drawingModule.changeAction( el.attributes['data-drawingmode'] ) );
    });

    // Listen for edit actions such as undo and clear
    querySelectorAll('[data-edit-action]').forEach((HtmlElement el) {
      el.onClick.listen((e) => _drawingModule.performEditAction( el.attributes['data-edit-action'] ) );
    });
    
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
  }
  
  /// Setup events that originate from the drawingModule and effect the user interface
  void _setupIncommingEvents() {
    _drawingModule.eventEmitter.on(DrawingTool.ON_ACTION_CHANGED, onActionChanged );
    _drawingModule.eventEmitter.on(DrawingTool.ON_DRAW_POINTS_CHANGED, onDrawPointsChanged );
    _drawingModule.eventEmitter.on(DrawingTool.ON_MIRROR_MODE_CHANGED, onMirrorModeChanged );
    _drawingModule.eventEmitter.on(DrawingTool.ON_SIDES_CHANGED, onSideCountChanged );
    _drawingModule.eventEmitter.on(DrawingTool.ON_SCALE_CHANGED, onScaleChanged );
    _drawingModule.eventEmitter.on(DrawingTool.ON_OPACITY_CHANGED, onOpacityChanged );
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
