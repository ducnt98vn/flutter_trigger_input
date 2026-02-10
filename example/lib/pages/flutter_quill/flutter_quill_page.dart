import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_trigger_input/extensions/string_ext.dart';
import 'package:flutter_trigger_input/flutter_trigger_input.dart';
import 'package:flutter_trigger_input_example/pages/flutter_quill/widgets/mention_embed.dart';
import 'package:flutter_trigger_input_example/pages/flutter_quill/widgets/mention_embed_builder.dart';

class FlutterQuillPage extends StatefulWidget {
  const FlutterQuillPage({super.key});

  @override
  State<FlutterQuillPage> createState() => _FlutterQuillPageState();
}

class _FlutterQuillPageState extends State<FlutterQuillPage> {
  QuillController _quillController = QuillController.basic();
  final LayerLink _layerLink = LayerLink();
  int? _lastAtIndex;
  String _currentQuery = '';

  final ScrollController _suggestionScrollController = ScrollController();

  final List<SuggestionInfo> suggestResults = [];
  final fullSuggestions = List.generate(
    50,
    (index) => SuggestionInfo(
      name: faker.person.name(),
      id: faker.guid.guid(),
    ),
  );

  @override
  void initState() {
    super.initState();

    _quillController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _suggestionScrollController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final selection = _quillController.selection;
    if (!selection.isCollapsed) return;

    final plainText = _quillController.document.toPlainText();
    final cursorIndex = selection.start;
    final textBeforeCursor = plainText.substring(0, cursorIndex);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');

    if (lastAtIndex != -1) {
      final query = textBeforeCursor.substring(lastAtIndex + 1);

      final isAtStart = lastAtIndex == 0 ||
          textBeforeCursor[lastAtIndex - 1] == ' ' ||
          textBeforeCursor[lastAtIndex - 1] == '\n';

      if (isAtStart && !query.contains(' ')) {
        suggestResults.clear();
        for (var item in fullSuggestions) {
          if (item.name.removeVietnameseAccent().contains(query)) {
            suggestResults.add(item);
          }
        }

        setState(() {
          _lastAtIndex = lastAtIndex;
          _currentQuery = query;
        });
        return;
      }
    }

    if (suggestResults.isNotEmpty) {
      suggestResults.clear();
    }
  }

  void _hideMentionMenu() {
    suggestResults.clear();
  }

  void _addMention(SuggestionInfo value) {
    if (_lastAtIndex != null) {
      _onUserSelected(value, _lastAtIndex!, _currentQuery);
    }
  }

  void _onUserSelected(SuggestionInfo user, int atIndex, String query) {
    // Độ dài cần xóa = dấu @ (1) + từ khóa query
    final lengthToRemove = 1 + query.length;

    // Xóa phần text thô
    _quillController.replaceText(atIndex, lengthToRemove, '', null);

    // Chèn Embed tại đúng vị trí đó
    _quillController.replaceText(
      atIndex,
      0,
      MentionEmbed(jsonEncode(user.toJson())),
      null,
    );

    _hideMentionMenu();
  }

  // void _addTagNameToTextInput() {
  //   // final index = _quillController.selection.baseOffset;
  //   // _quillController.replaceText(0, 1, '', null);

  //   _quillController.replaceText(
  //     0,
  //     0,
  //     MentionEmbed(faker.person.name()),
  //     null,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Quill'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: ElevatedButton(
            //     onPressed: _addTagNameToTextInput,
            //     child: const Text('Add Random Mention'),
            //   ),
            // ),
            Expanded(child: _buildSuggestPanel()),
            QuillSimpleToolbar(
              controller: _quillController,
              config: const QuillSimpleToolbarConfig(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: QuillEditor.basic(
                    controller: _quillController,
                    config: QuillEditorConfig(
                      padding: EdgeInsets.zero,
                      embedBuilders: [
                        // ...DefaultEmbedBuilders
                        //     .builders(), // Giữ lại các bản mặc định (ảnh, video)
                        MentionEmbedBuilder(), // Thêm builder của bạn vào
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestPanel() {
    if (suggestResults.isEmpty) {
      return Container();
    }

    return Scrollbar(
      controller: _suggestionScrollController,
      child: ListView.builder(
        controller: _suggestionScrollController,
        reverse: true,
        itemCount: suggestResults.length,
        itemBuilder: (context, index) {
          final details = suggestResults[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              backgroundImage: NetworkImage(
                'https://api.dicebear.com/7.x/avataaars/png?seed=${details.name}',
              ),
            ),
            title: Text(
              details.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle:
                Text("@${details.name.replaceAll(' ', '_').toLowerCase()}"),
            onTap: () => _addMention(details),
          );
        },
      ),
    );
  }
}
