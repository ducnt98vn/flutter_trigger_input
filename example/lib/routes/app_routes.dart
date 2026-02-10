import 'package:flutter/material.dart';
import 'package:flutter_trigger_input_example/pages/flutter_quill/flutter_quill_page.dart';
import 'package:flutter_trigger_input_example/pages/home/home_page.dart';
import 'package:flutter_trigger_input_example/pages/trigger_input/trigger_input_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String flutterQuill = '/flutter-quill';
  static const String triggerInput = '/trigger-input';
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
      flutterQuill: (context) => const FlutterQuillPage(),
      triggerInput: (context) => const TriggerInputPage(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case triggerInput:
        return MaterialPageRoute(
            builder: (context) => const TriggerInputPage());
      case flutterQuill:
        return MaterialPageRoute(
            builder: (context) => const FlutterQuillPage());
      default:
        return null;
    }
  }
}
