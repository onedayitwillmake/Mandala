part of DrawingToolLib;

class SvgRenderer {

  Svg.SvgElement _svg;
  Svg.DefsElement defs;

  //  Current State
  num               _lineWidth;
  String            _strokeStyle;
  String            _fillStyle;
  num               _opacity = 1.0;

  Svg.GElement      _currentGroup;
  Svg.PathElement   _currentPath;
  StringBuffer      _currentMatrixString;
  StringBuffer      _currentPathString;

  SvgRenderer( int width, int height ) {
    _svg = new Svg.SvgElement.tag("svg");
    _svg.attributes['width'] = width.toString();
    _svg.attributes['height'] = height.toString();
    _svg.attributes['version'] = "1.1";

    defs = new Svg.SvgElement.tag("defs");
    _svg.nodes.add( defs );

    noStroke();
    noFill();
  }

  // Core
  void moveTo(num x, num y) {
    _currentPathString.write("M${x} ${y} ");
  }
  void lineTo(num x, num y) {
    _currentPathString.write("L${x} ${y} ");
  }
  void quadraticCurveTo(num cpx, num cpy, num x, num y) {
    _currentPathString.write("Q${cpx} ${cpy} ${x} ${y} ");
  }
  
  void groupStart(){
    _currentGroup = new Svg.SvgElement.tag("g") as Svg.GElement;
    _strokeStyle = "none";
    _fillStyle = "none";
    _currentMatrixString = new StringBuffer();
  }
  void groupEnd() {
    _currentGroup.attributes['transform'] = _currentMatrixString.toString();
    _svg.nodes.add( _currentGroup );
  }
  
  // Matrix Transform
  void setTransform(num m11, num m12, num m21, num m22, num dx, num dy) {
    _currentMatrixString.write("matrix(${m11} ${m12} ${m21} ${m22} ${dx} ${dy}) " );
  }
  void translate(num tx, num ty) {
    _currentMatrixString.write("translate(${tx}, ${ty}) ");
  }
  void rotate(num angle) {
    num angleInDegrees = angle * 180.0 / PI;
    _currentMatrixString.write("rotate(${angleInDegrees}) ");
  }
  
  // Shapes
  void arc(num x,  num y,  num radius,  num startAngle, num endAngle, [bool anticlockwise = false]) {
    // Due to some SVG thing, if the arc is 360 degrees - it wont render -
    // So make it 359.9999 degrees
    bool closeArc = false;
    if( startAngle.abs() + endAngle.abs() == PI*2 ) {
      endAngle *= 0.9999999;
      closeArc = true;
    }
    
    
    // Convert to Polar Coordinates
    Geom.Point start = new Geom.Point(x + cos(startAngle - PI / 2) * radius, y + sin(startAngle - PI / 2) * radius);
    Geom.Point end = new Geom.Point(x + cos(endAngle - PI / 2) * radius, y + sin(endAngle - PI / 2) * radius);
    
    String arcSweep = (endAngle - startAngle <= PI) ? "0" : "1";
    
    _currentPathString.write("M${start.x} ${start.y} ");
    _currentPathString.write("A${radius} ${radius} 1 1 1 ${end.x} ${end.y} ${closeArc ? 'Z' : '' }");
  }

  void rect(num x, num y, num width, num height) {
    var rect = new Svg.SvgElement.tag("rect");
    rect.attributes["width"] = width.toString();
    rect.attributes["height"] = height.toString();
    rect.attributes["x"] = x.toString();
    rect.attributes["y"] = y.toString();
    
    _currentGroup.nodes.add(rect);
  }
  
  /// Create a new path
  void beginPath() {
    _currentPathString = new StringBuffer();
    _currentPath = new Svg.SvgElement.tag("path");
    
    _currentPath.attributes["stroke"] = _strokeStyle;
    _currentPath.attributes["fill"] = _fillStyle;
    _currentPath.attributes["opacity"] = _opacity.toStringAsPrecision(2);
    _currentPath.attributes["stroke-width"] = _lineWidth.toString();
    
    _currentGroup.nodes.add(_currentPath);
  }
  
  /// Close the path
  void closePath() {
    // write to the d[ata] attribute
    _currentPath.attributes["d"] = _currentPathString.toString();
  }
  
  // Fill/Stroke
  void stroke() {
    _currentPath.attributes['stroke'] = _strokeStyle;
  }
  void noStroke() {
    _strokeStyle = "none";
  }

  void fill() {
    _currentPath.attributes['fill'] = _fillStyle;
  }
  
  void noFill() {
    _fillStyle = "none";
  }

  // Color
  void setStrokeColorRgb(int r, int g, int b, [num a = 1]) {
    int color = (r << 16) + (g << 8) + (b << 0);
    
    _strokeStyle = '#${((1 << 24) + (r << 16) + (g << 8) + b).toRadixString(16).substring(1, 7)}'; 
    _opacity = a;
  }
  void setStrokeColorHsl(int h, num s, num l, [num a = 1]) {
    _strokeStyle = 'hsla($h, $s%, $l%, $a)';
  }
  void setFillColorRgb(int r, int g, int b, [num a = 1]) {
    int color = (r << 16) + (g << 8) + (b << 0);
    
    _fillStyle = '#${((1 << 24) + (r << 16) + (g << 8) + b).toRadixString(16).substring(1, 7)}'; 
    _opacity = a;
  }
  void setFillColorHsl(int h, num s, num l, [num a = 1]) {
    _fillStyle = 'hsla($h, $s%, $l%, $a)';
  }

  // Props
  Svg.SvgElement get svg => _svg;

  num     get lineWidth => _lineWidth;
          set lineWidth( num value ) => _lineWidth = value;

  String  get fillStyle => _fillStyle;
          set fillStyle( String value ) => _fillStyle = value;

  String  get strokeStyle => _strokeStyle;
          set strokeStyle( String value ) => _strokeStyle = value;
}