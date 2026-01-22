import 'package:flutter_trigger_input/src/utils/bbob_dart/lib/bbob_dart.dart';

class Convert {
  static String nodeListToString(List<Node> source) {
    StringBuffer result = StringBuffer();
    for (var item in source) {
      result.write(item is Text ? item.text : item.toString());
    }
    return result.toString();
  }
}
