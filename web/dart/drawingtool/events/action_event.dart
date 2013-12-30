part of DrawingToolLib;

class ActionEvent {
  /// Emitted when the user has started the drawing interaction (usually mousedown)
  static const String ON_DRAWING_INTERACTION_STARTED = "ActionEvent.ON_DRAWING_INTERACTION_STARTED";
  /// Emitted when the user has finished the drawing interaction (varies by action)
  static const String ON_DRAWING_INTERACTION_FINISHED = "ActionEvent.ON_DRAWING_INTERACTION_FINISHED";
}