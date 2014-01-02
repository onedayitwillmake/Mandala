part of DrawingToolLib;

class ActionSettings {
  num lineWidth = 0.5;
  num opacity = 0.5;
  String strokeStyle = "rgba(255,255,255,0.25)";
  String fillStyle = "rgba(255,255,255,0.25)";

  ColorValue strokeColor = new ColorValue.fromRGB(255, 255, 255);
  ColorValue fillColor = new ColorValue.fromRGB(255, 255, 255);

  ActionSettings();

  void execute(dynamic ctx) {
    ctx.lineWidth = lineWidth;
    ctx.setStrokeColorRgb(strokeColor.r, strokeColor.g, strokeColor.b,opacity);
    ctx.setFillColorRgb(fillColor.r, fillColor.g, fillColor.b, opacity);
  }

  void executeForSvg(SvgRenderer ctx) {
    ctx.lineWidth = lineWidth;
    if( strokeStyle == null ) {
      ctx.noStroke();
    } else {
      ctx.setStrokeColorRgb(strokeColor.r, strokeColor.g, strokeColor.b,opacity);
    }

    if( fillStyle == null ) {
      ctx.noFill();
    } else {
      ctx.setFillColorRgb(fillColor.r, fillColor.g, fillColor.b,opacity);
    }
  }
}


// This is shamelessly borrowed from:
// https://github.com/coderespawn/dart-color-picker/blob/master/lib/utils/color_value.dart
class ColorValue {
  /** Red color component. Value ranges from [0..255] */
  int r;

  /** Green color component. Value ranges from [0..255] */
  int g;

  /** Blue color component. Value ranges from [0..255] */
  int b;

  /**
   * Parses the color value with the following format:
   *    "#fff"
   *    "#ffffff"
   *    "255, 255, 255"
   */
  ColorValue.from(String value) {
    if (value.startsWith("#")) {
      parseHex(value);
    }
    else if (value.contains(",")) {
      parseRgb(value);
    }
  }

  ColorValue() : r = 0, g = 0, b = 0;
  ColorValue.fromRGB(this.r, this.g, this.b);
  ColorValue.copy(ColorValue other) {
    this.copyFrom( other );
  }

  void copyFrom( ColorValue other ) {
    this.r = other.r;
    this.g = other.g;
    this.b = other.b;
  }

  void set(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }

  /**
   * Parses the color value in the format FFFFFF or FFF
   * and is not case-sensitive
   */
  void parseHex(String hex) {
    hex = hex.substring(1);
    if (hex.length != 3 && hex.length != 6) {
      throw new Exception("Invalid color hex format");
    }

    if (hex.length == 3) {
      var a = hex.substring(0, 1);
      var b = hex.substring(1, 2);
      var c = hex.substring(2, 3);
      hex = "$a$a$b$b$c$c";
    }
    var hexR = hex.substring(0, 2);
    var hexG = hex.substring(2, 4);
    var hexB = hex.substring(4, 6);
    r = int.parse("0x$hexR");
    g = int.parse("0x$hexG");
    b = int.parse("0x$hexB");
  }

  void parseRgb( String value ) {
    List<String> tokens = value.split(",");
    if (tokens.length < 3) {
      throw new Exception("Invalid color value format");
    }
    tokens[0] = tokens[0].substring(4);
    tokens[2] = tokens[2].substring(0, tokens[2].length - 1 );
    r = int.parse(tokens[0]);
    g = int.parse(tokens[1]);
    b = int.parse(tokens[2]);
    r = max(0, min(255, r));
    g = max(0, min(255, g));
    b = max(0, min(255, b));
  }

  ColorValue operator* (num value) {
    return new ColorValue.fromRGB(
        (r * value).toInt(),
        (g * value).toInt(),
        (b * value).toInt());
  }
  ColorValue operator+ (ColorValue other) {
    return new ColorValue.fromRGB(
        r + other.r,
        g + other.g,
        b + other.b);
  }

  ColorValue operator- (ColorValue other) {
    return new ColorValue.fromRGB(
        r - other.r,
        g - other.g,
        b - other.b);
  }

  String toString() => "rgba($r, $g, $b, 1.0)";
  String toRgbString() => "$r, $g, $b";
}