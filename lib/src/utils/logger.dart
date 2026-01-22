import 'dart:developer' as dev;

class Logger {
  // Prefix để nhận diện log của package này
  static const String _tag = 'TriggerInputPackage';

  static void info(String message) {
    dev.log(message, name: _tag);
  }

  // static void error(String message, [Object? error, StackTrace? stack]) {
  //   dev.log(
  //     'ERROR: $message',
  //     name: _tag,
  //     error: error,
  //     stackTrace: stack,
  //     level: 1000, // Mức độ nghiêm trọng
  //   );
  // }
}
