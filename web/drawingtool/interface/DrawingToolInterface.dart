part of DrawingToolLib;

class DrawingToolInterface {
  DrawingTool _drawingModule;
  HtmlElement _lastSelectedTool;
  
  RangeInputElement _$slideCountSlider = null;

  DrawingToolInterface( this._drawingModule ) {
    // Pressing interface button will
    querySelectorAll('[data-drawingmode]').forEach((HtmlElement el) {
      el.onClick.listen((e) => onWantsToChangeAction(el) );
    });
    
    querySelectorAll('[data-edit-action]').forEach((HtmlElement el) {
      el.onClick.listen((e) {
        _drawingModule.performEditAction( el.attributes['data-edit-action'] );
      });
    });
    
    _$slideCountSlider = querySelector("#interface-sidecount-slider");
    _$slideCountSlider.onChange.listen((e){
      print(_$slideCountSlider.value);
    });
    
  }

  onWantsToChangeAction( HtmlElement el ) {
    print("${el.attributes['data-drawingmode']}");

    var result = _drawingModule.changeAction( el.attributes['data-drawingmode'] );

    // Swap as 'active'
    if( result ) {
      if( _lastSelectedTool != null ) {
        _lastSelectedTool.classes.remove('active');
      }
      el.classes.add('active');
      _lastSelectedTool = el;
    }
  }
}
