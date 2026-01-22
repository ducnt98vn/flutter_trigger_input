import 'package:flutter/material.dart';

class KeywordPanel extends StatelessWidget {
  final String keyword;

  const KeywordPanel({super.key, required this.keyword});

  @override
  Widget build(BuildContext context) {
    if (keyword.isEmpty) return SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Text("Trigger:",
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(
                  keyword.substring(0, 1),
                  style: TextStyle(
                      color: Colors.blue.shade900, fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            height: 10,
            width: 1,
            color: Colors.black,
          ),
          Flexible(
            flex: 3,
            child: Row(
              children: [
                Text("Keyword:",
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(
                  keyword.substring(1),
                  style: TextStyle(
                      color: Colors.blue.shade900, fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
