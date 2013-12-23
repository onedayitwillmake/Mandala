part of DrawingToolLib;

class DrawingToolEvent {
/// Emitted when the current action has changed
  static const String ON_ACTION_CHANGED = "DrawingTool.ON_ACTION_CHANGED";
/// Emitted when mirror mode has been toggled
  static const String ON_MIRROR_MODE_CHANGED = "DrawingTool.ON_MIRROR_MODE_CHANGED";
/// Emitted when shouldDrawEditablePoints has been toggled
  static const String ON_DRAW_POINTS_CHANGED = "DrawingTool.ON_DRAW_POINTS_CHANGED";
/// Emitted when the number of sides is updated
  static const String ON_SIDES_CHANGED = "DrawingTool.ON_SIDES_CHANGED";
/// Emitted when the number of sides is updated
  static const String ON_SCALE_CHANGED = "DrawingTool.ON_SCALE_CHANGED";
/// Emitted when the opacity value has been updated
  static const String ON_OPACITY_CHANGED = "DrawingTool.ON_OPACITY_CHANGED";
/// Emitted when the line-width value has been updated
  static const String ON_LINEWIDTH_CHANGED = "DrawingTool.ON_LINEWIDTH_CHANGED";
}