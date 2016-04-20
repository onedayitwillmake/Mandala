library DrawingToolLib;

import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:js';
import 'dart:svg' as Svg;
import 'dart:math' show PI, Rectangle, sin, cos, max, min;
import 'dart:collection';

import 'package:stagexl/stagexl.dart' as Geom show Matrix, Point;
import '../linegeneralization/line_generalization.dart' as LineGeneralization;

part 'actions/BaseAction.dart';
part 'actions/ActionSettings.dart';
part 'actions/RegularStrokeAction.dart';
part 'actions/RegularFillAction.dart';
part 'actions/SmoothStrokeAction.dart';
part 'actions/SmoothFillAction.dart';
part 'actions/PolygonalStrokeAction.dart';
part 'actions/PolygonalFillAction.dart';

part 'svgrender/SvgRenderer.dart';

part 'events/drawing_tool_event.dart';
part 'events/action_event.dart';
part 'events/interface_event.dart';
part 'events/SharedDispatcher.dart';
part 'DrawingTool.dart';
part 'interface/DrawingToolInterface.dart';