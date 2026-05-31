import 'dart:async';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_trigger_input/flutter_trigger_input.dart';
import 'package:flutter_trigger_input_example/pages/trigger_input/widgets/keyword_panel.dart';
import 'package:flutter_trigger_input_example/utils/filtering_algorithm.dart';

class TriggerInputPage extends StatefulWidget {
  const TriggerInputPage({super.key});

  @override
  State<TriggerInputPage> createState() => _TriggerInputPageState();
}

class _TriggerInputPageState extends State<TriggerInputPage> {
  final ValueNotifier<String> fullText = ValueNotifier('');
  final ValueNotifier<String> triggeredKey = ValueNotifier('');
  final ValueNotifier<bool> enableLinkReplacement = ValueNotifier(true);

  late final TriggerInputController<SuggestionInfo> _controller;
  final ScrollController _suggestionScrollController = ScrollController();
  Timer? _debounceTimer;

  final userSuggestions = List.generate(
    20,
    (index) => SuggestionInfo(
      name: faker.person.name(),
      id: faker.guid.guid(),
    ),
  );

  final hashtagSuggestions = [
    SuggestionInfo(id: '1', name: 'flutter'),
    SuggestionInfo(id: '2', name: 'dart'),
    SuggestionInfo(id: '3', name: 'mobile_dev'),
    SuggestionInfo(id: '4', name: 'coding'),
  ];

  @override
  void initState() {
    super.initState();

    // Khởi tạo controller với các cấu hình trigger khác nhau
    _controller = TriggerInputController<SuggestionInfo>(
      triggers: [
        Mention(
          trigger: '@',
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        Mention(
          trigger: '#',
          style: const TextStyle(
            color: Colors.pink,
            backgroundColor: Colors.amberAccent,
          ),
          contextMenuLabel: 'Copy Hashtag Data',
          onContextMenuPressed: (markup) {
            debugPrint('Custom action for hashtag: $markup');
            Clipboard.setData(ClipboardData(text: markup));
          },
        ),
      ],
    );

    _controller.tfController.addListener(() {
      Future.microtask(() {
        fullText.value = _controller.tfController.markupText;
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _suggestionScrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _addMention(SuggestionInfo value) {
    _controller.state.suggestionInfos.value = [];
    _controller.addMention(value);
  }

  void _addRandomMention() {
    _controller.insertEntityAtStart(
      entity: SuggestionInfo(
        id: faker.guid.guid(),
        name: faker.person.name(),
      ),
      trigger: '@',
    );
  }

  void onMentionSearchChanged(String trigger, String keyword) {
    triggeredKey.value = '$trigger$keyword';

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      List<SuggestionInfo> source = [];
      if (trigger == '@') {
        source = userSuggestions;
      } else if (trigger == '#') {
        source = hashtagSuggestions;
      } else {
        source = [
          SuggestionInfo(id: 'https://flutter.dev', name: 'Flutter Website')
        ];
      }

      final results = FilteringAlgorithm().execute(
        trigger,
        keyword,
        source,
      );

      _controller.state.suggestionInfos.value = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Multi-Trigger Input'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildFullTextPanel(),
                      _buildKeywordPanel(),
                      _buildSettingsPanel(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            ElevatedButton(
                              onPressed: _addRandomMention,
                              child: const Text('Add @Mention'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _controller.insertEntityAtStart(
                                  entity: SuggestionInfo(
                                      id: 'hot', name: 'trending'),
                                  trigger: '#',
                                );
                              },
                              child: const Text('Add #Hashtag'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final currentText =
                                    _controller.tfController.text;
                                final selection =
                                    _controller.tfController.selection;
                                final start = selection.baseOffset
                                    .clamp(0, currentText.length);
                                final end = selection.extentOffset
                                    .clamp(0, currentText.length);

                                final linkSegment = TextSegment(
                                  text: 'Google',
                                  attributes: {
                                    'link': {'url': 'https://google.com'}
                                  },
                                );

                                // Cập nhật cache trước để Renderer không xử lý đè lên gây lặp chữ
                                final newFullText = currentText.replaceRange(
                                    start, end, 'Google');
                                _controller.state.cacheDisplayText =
                                    newFullText;
                                _controller.state.cacheSelection =
                                    TextSelection.collapsed(
                                  offset: start + 'Google'.length,
                                );

                                _controller.tfController
                                    .replaceRangeWithSegment(
                                  start,
                                  end,
                                  linkSegment,
                                );
                              },
                              child: const Text('Add Link'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                const url = 'https://flutter.dev';
                                final currentText =
                                    _controller.tfController.text;
                                final selection =
                                    _controller.tfController.selection;
                                final newText = currentText.replaceRange(
                                  selection.baseOffset
                                      .clamp(0, currentText.length),
                                  selection.extentOffset
                                      .clamp(0, currentText.length),
                                  url,
                                );

                                _controller.tfController.value =
                                    TextEditingValue(
                                  text: newText,
                                  selection: TextSelection.collapsed(
                                    offset: selection.baseOffset + url.length,
                                  ),
                                );
                              },
                              child: const Text('Paste URL'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildSuggestPanel(),
                ),
              ],
            ),
          ),
          ValueListenableBuilder(
            valueListenable: enableLinkReplacement,
            builder: (context, enabled, child) {
              return TriggerInputField<SuggestionInfo>(
                controller: _controller,
                allowSpace: true,
                enableLinkReplacement: enabled,
                linkReplacementText: 'See link',
                decoration: const InputDecoration(
                  hintText: 'Type @ for users, # for hashtags, [ for links...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 4,
                onMentionSearchChanged: onMentionSearchChanged,
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSuggestPanel() {
    return AnimatedBuilder(
      animation: _controller.state.suggestionInfos,
      builder: (_, __) {
        final list = _controller.state.suggestionInfos.value;
        if (list.isEmpty) return const SizedBox.shrink();

        return Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Scrollbar(
            controller: _suggestionScrollController,
            thumbVisibility: true,
            child: ListView.builder(
              controller: _suggestionScrollController,
              shrinkWrap: true,
              reverse: true,
              padding: EdgeInsets.zero,
              itemCount: list.length,
              itemBuilder: (context, index) {
                final details = list[index];
                final trigger =
                    triggeredKey.value.isNotEmpty ? triggeredKey.value[0] : '';

                return ListTile(
                  leading: trigger == '@'
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://api.dicebear.com/7.x/avataaars/png?seed=${details.name}',
                          ),
                        )
                      : Icon(trigger == '#' ? Icons.tag : Icons.link),
                  title: Text(details.name),
                  subtitle: Text(details.id),
                  onTap: () => _addMention(details),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullTextPanel() {
    return ValueListenableBuilder(
      valueListenable: fullText,
      builder: (_, value, __) {
        return Container(
          margin: const EdgeInsets.all(12),
          height: 150,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeywordPanel() {
    return ValueListenableBuilder(
      valueListenable: triggeredKey,
      builder: (_, value, __) {
        return KeywordPanel(keyword: value);
      },
    );
  }

  Widget _buildSettingsPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          const Text('Enable Link Replacement:'),
          ValueListenableBuilder(
            valueListenable: enableLinkReplacement,
            builder: (_, value, __) {
              return Switch(
                value: value,
                onChanged: (newValue) => enableLinkReplacement.value = newValue,
              );
            },
          ),
        ],
      ),
    );
  }
}
