import 'package:flutter/material.dart';

class KeywordPanel extends StatelessWidget {
  final String keyword;

  const KeywordPanel({super.key, required this.keyword});

  @override
  Widget build(BuildContext context) {
    if (keyword.isEmpty) return SizedBox.shrink();

    final keywordScrollController = ScrollController();

    return Container(
      height: 200,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
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
          Divider(color: Colors.grey.shade300, height: 20),
          Expanded(
            child: Row(
              children: [
                Text(
                  "Keyword:",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: keywordScrollController,
                    child: SingleChildScrollView(
                      controller: keywordScrollController,
                      physics: BouncingScrollPhysics(),
                      child: Text(
                        keyword.substring(1),
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
