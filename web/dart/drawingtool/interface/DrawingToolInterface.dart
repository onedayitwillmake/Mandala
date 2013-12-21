part of DrawingToolLib;

class DrawingToolInterface {
  DrawingTool _drawingModule;
  HtmlElement _lastSelectedTool;

  RangeInputElement _$slideCountSlider = null;
  RangeInputElement _$opacitySlider = null;

  DrawingToolInterface( this._drawingModule ) {
    // Pressing interface button will
    querySelectorAll('[data-drawingmode]').forEach((HtmlElement el) {
      el.onClick.listen((e) => onWantsToChangeAction(el) );
    });

    // Listen for edit actions such as undo
    querySelectorAll('[data-edit-action]').forEach((HtmlElement el) {
      el.onClick.listen((e) {
        _drawingModule.performEditAction( el.attributes['data-edit-action'] );
      });
    });


    // Mirroring toggle
    CheckboxInputElement mirrorCheckbox = ( querySelector("[name=toggle-mirroring]") as CheckboxInputElement );
    mirrorCheckbox.checked = true;
    mirrorCheckbox.parent.onClick.listen((e){
      mirrorCheckbox.checked = !mirrorCheckbox.checked;
      _drawingModule.isMirrored = mirrorCheckbox.checked;
      mirrorCheckbox.nextElementSibling.text = "Mirror Mode ";// + (mirrorCheckbox.checked ? "On" : "Off");
    });

    CheckboxInputElement drawPointsCheckbox = ( querySelector("[name=toggle-draw-points]") as CheckboxInputElement );
    drawPointsCheckbox.checked = true;
    drawPointsCheckbox.parent.onClick.listen((e){
      drawPointsCheckbox.checked = !drawPointsCheckbox.checked;
      _drawingModule.shouldDrawEditablePoints = drawPointsCheckbox.checked;
      drawPointsCheckbox.nextElementSibling.text = "Draw Points ";// + (drawPointsCheckbox.checked ? "On" : "Off");
    });

    // Scale count slider
    RangeInputElement scaleSlider = ( querySelector("#interface-scale-slider") as RangeInputElement );
    scaleSlider.onChange.listen((e){
      _drawingModule.scale = double.parse(scaleSlider.value) / 100.0;
      querySelector("#interface-scale-slider-text").text = "Zoom: " + _drawingModule.scale.toStringAsPrecision(2);
    });

    // Side count slider
    _$slideCountSlider = ( querySelector("#interface-sidecount-slider") as RangeInputElement );
    _$slideCountSlider.onChange.listen((e){
      querySelector("#interface-sidecount-slider-text").text = "Sides: " + _$slideCountSlider.value;
      _drawingModule.sides = int.parse(_$slideCountSlider.value);
    });

    // Opacity slider
    _$opacitySlider = ( querySelector("#interface-opacity-slider") as RangeInputElement );
    _$opacitySlider.onChange.listen((e){
      querySelector("#interface-opacity-slider-text").text = "Alpha: ." + _$opacitySlider.value;
      _drawingModule.performEditAction( "alpha", double.parse( _$opacitySlider.value ) / 100.0 );
    });
  }

  onWantsToChangeAction( HtmlElement el ) {
    var result = _drawingModule.changeAction( el.attributes['data-drawingmode'] );
    if( result ) {
      querySelectorAll('[data-drawingmode]').forEach((HtmlElement otherEl) => otherEl.classes.remove('active') );
      el.classes.add('active');
      _lastSelectedTool = el;
    }
  }
}
