library DrawingToolLib;
import 'dart:html';
import 'dart:math' show Point, PI, Rectangle;
import 'dart:collection';
import 'package:stagexl/stagexl.dart' as StageXL show Matrix;
import '../linegeneralization/line_generalization.dart' as LineGeneralization;

part 'DrawingTool.dart';
part 'actions/BaseAction.dart';
part 'actions/ActionSettings.dart';
part 'actions/RegularStrokeAction.dart';
part 'actions/SmoothStrokeAction.dart';
part 'actions/PolygonalStrokeAction.dart';
part 'actions/PolygonalFillAction.dart';
part 'interface/DrawingToolInterface.dart';
