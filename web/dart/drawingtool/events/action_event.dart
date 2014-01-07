part of DrawingToolLib;

class ActionEvent {
  /// Emitted when the user has started the drawing interaction (usually mousedown)
  static const String ON_DRAWING_INTERACTION_STARTED = "ActionEvent.ON_DRAWING_INTERACTION_STARTED";
  /// Emitted when the user has finished the drawing interaction (varies by action)
  static const String ON_DRAWING_INTERACTION_FINISHED = "ActionEvent.ON_DRAWING_INTERACTION_FINISHED";
  /// When an action is now in a confirmable state, for example you have drawn a stroke in the smoothline action, or have a few points in the polygonal action
  /// This is used to show that confirm has an effect on THIS action, otherwise it would always appear to be there making the user think it did nothing related to the tool
  static const String ON_BECAME_CONFIRMABLE = "ActionEvent.ON_BECAME_CONFIRMABLE";
  /// Action needs to be reconfirmed at later time (for example a new path has just started being drawn)
  static const String ON_BECAME_UNCONFIRMED = "ActionEvent.ON_BECAME_UNCONFIRMED";
}