import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_trigger_input/flutter_trigger_input.dart';

class MentionEmbedBuilder implements EmbedBuilder {
  @override
  String get key => 'mention'; // Phải trùng với mentionType ở trên

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final data =
        SuggestionInfo.fromJson(jsonDecode(embedContext.node.value.data));

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chạm vào user: ${data.toJson()}'),
            action: SnackBarAction(
              label: 'Sao chép',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: data.toJson().toString()))
                    .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Đã sao chép vào bộ nhớ tạm!')),
                  );
                });
              },
            ),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "@${data.name}",
          style:
              const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  WidgetSpan buildWidgetSpan(Widget widget) {
    return WidgetSpan(child: widget);
  }

  @override
  bool get expanded => false;
}
