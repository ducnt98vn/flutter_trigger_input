import 'package:flutter/material.dart';

class Annotation {
  Annotation({required this.trigger, this.style, this.markupBuilder});

  String trigger;
  TextStyle? style;

  final String Function(String trigger, String mention, String value)?
      markupBuilder;
}
