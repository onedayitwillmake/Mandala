part of DrawingToolLib;

class DrawingToolInterface {
  DrawingTool _drawingModule;
  HtmlElement _lastSelectedTool;

  RangeInputElement _$sideCountSlider = null;
  RangeInputElement _$scaleSlider = null;
  RangeInputElement _$opacitySlider = null;
  RangeInputElement _$lineWidthSlider = null;

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
    
    querySelector("#nu-interface-save-svg").onClick.listen( _onSvgSave );
    
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
  }
  
  /// Setup events that originate from the drawingModule and effect the user interface
  void _setupIncommingEvents() {
    _drawingModule.eventEmitter.on(DrawingTool.ON_ACTION_CHANGED, onActionChanged );
    _drawingModule.eventEmitter.on(DrawingTool.ON_DRAW_POINTS_CHANGED, onDrawPointsChanged );
    _drawingModule.eventEmitter.on(DrawingTool.ON_MIRROR_MODE_CHANGED, onMirrorModeChanged );
    _drawingModule.eventEmitter.on(DrawingTool.ON_SIDES_CHANGED, onSideCountChanged );
    _drawingModule.eventEmitter.on(DrawingTool.ON_SCALE_CHANGED, onScaleChanged );
    _drawingModule.eventEmitter.on(DrawingTool.ON_OPACITY_CHANGED, onOpacityChanged );
    _drawingModule.eventEmitter.on(DrawingTool.ON_LINEWIDTH_CHANGED, onLineWidthChanged );
  }
  
  /// Save out an SVG version of the mandala
  void _onSvgSave(e) {
    // Create the SVG 
    Svg.SvgElement svg = _drawingModule.saveSvg();
    
    // Convert to blob
    var blob = new Blob([svg.outerHtml], "image/svg+xml");
    
    // Open preview window with download link
    var previewWindow = window.open("", "");
    var a = new AnchorElement(href: Url.createObjectUrlFromBlob( blob ) );
    a.text = "Download";
    a.style.display = "block";
    a.download = "mandala.svg";
    a.onClick.listen((e) { // clenaup
      new Future.delayed(new Duration(seconds:2), () => Url.revokeObjectUrl(a.href));
    });
    
    // Add the <a> tag, followed by the SVG
    previewWindow.document.body.nodes.add(a); 
    previewWindow.document.body.nodes.add(svg);
    
    // Open window with just SVG data as XML
//    new Future.delayed(new Duration(seconds:), () => window.open(Url.createObjectUrlFromBlob( blob ), "svg-text") );
    //, "width=${(_drawingModule.width+50).toInt().toString()},height=${(_drawingModule.height+50).toInt().toString()},location=no,menubar=no");
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
    querySelector("#interface-line-width-slider-text").text = "Thickness: " + (lineWidth*100).toInt().toString();
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
