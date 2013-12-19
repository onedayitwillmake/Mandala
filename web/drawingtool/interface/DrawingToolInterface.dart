part of DrawingToolLib;

class DrawingToolInterface {
  DrawingTool _tool;

  DrawingToolInterface( this._tool ) {
    // Pressing interface button will
    querySelectorAll('[data-drawingmode]').forEach((HtmlElement el) {
      el.onClick.listen((e) => _tool.changeAction( el.attributes['data-drawingmode'] ) );
    });
  }
}
