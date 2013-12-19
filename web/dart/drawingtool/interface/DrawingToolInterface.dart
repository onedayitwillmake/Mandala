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


    // Listen for settings actions such as opacity and sidecount
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
    print("${el.attributes['data-drawingmode']}");

    var result = _drawingModule.changeAction( el.attributes['data-drawingmode'] );
    if( result ) {
      querySelectorAll('[data-drawingmode]').forEach((HtmlElement otherEl) => otherEl.classes.remove('active') );

      el.classes.add('active');
      _lastSelectedTool = el;
    }
  }
}
