import "dart:developer";

class Logger {
  void info(String message, {String name = "Info"}) {
    log(message, name: name, level: Level.info);
  }

  void success(String message, {String name = "Success"}) {
    log(message, name: name, level: Level.success);
  }

  void error(String message, {String name = "Error"}) {
    log(message, name: name, level: Level.error);
  }

  void severe(String message, {String name = "SEVERE"}) {
    log(message, name: name, level: Level.severe);
  }
}

class Level {
  static const int info = 0;
  static const int success = 10;
  static const int error = 20;
  static const int severe = 30;
}
