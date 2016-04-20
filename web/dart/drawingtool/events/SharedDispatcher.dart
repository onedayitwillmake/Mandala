part of DrawingToolLib;

/**
 * A simple "event" emitter for
 * Dart inspired by the classical
 * stuff used in JavaScript/ActionScript.
 */
library dart_events;

class EventEmitter {
  Map<String, List<Function>> _listeners = new Map<String, List<Function>>();

  EventEmitter();

  on(String type, Function handler) {
    // Create the channel if it doesn't exist
    _listeners.putIfAbsent(type, () {
      return new List<Function>();
    });

    List<Function> listeners = _listeners[type];
    bool exists = listeners.contains(handler);
    if (!exists) {
      listeners.add(handler);
    }
  }

  off(String type, Function handler) {
    if (_listeners.containsKey(type)) {
      List<Function> listeners = _listeners[type];
      int index = listeners.indexOf(handler);
      if (index != -1) {
        listeners.removeAt(index);
      }
    }
  }

  emit(String type, dynamic data) {
    if (_listeners.containsKey(type)) {
      List<Function> listeners = _listeners[type];
      listeners.forEach((Function item) {
        // Getting an exception with this (2013/01/07)
        //
        // Exception: UnimplementedError: Function.apply not implemented
        // Stack Trace: #0      Function.apply (dart:core-patch:729:5)
        // Function.apply(item, ...);
        // but I'd like to use Function.apply ...
        item(data);
      });
    }
  }

  Map<String, List<Function>> listeners () => _listeners;

}

class SharedDispatcher {
  static EventEmitter emitter = new EventEmitter();
}