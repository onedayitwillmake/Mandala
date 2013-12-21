library DrawingToolLib;
import 'dart:html';
import 'dart:math' show PI, Rectangle;
import 'dart:collection';
import 'package:dart_events/dart_events.dart';

import 'package:stagexl/stagexl.dart' as Geom show Matrix, Point;
import '../linegeneralization/line_generalization.dart' as LineGeneralization;

part 'DrawingTool.dart';
part 'actions/BaseAction.dart';
part 'actions/ActionSettings.dart';
part 'actions/RegularStrokeAction.dart';
part 'actions/RegularFillAction.dart';
part 'actions/SmoothStrokeAction.dart';
part 'actions/SmoothFillAction.dart';
part 'actions/PolygonalStrokeAction.dart';
part 'actions/PolygonalFillAction.dart';
part 'interface/DrawingToolInterface.dart';
