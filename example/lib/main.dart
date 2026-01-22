import 'package:faker/faker.dart' hide Image;
import 'package:flutter/material.dart';
import 'package:flutter_trigger_input/flutter_trigger_input.dart';

import 'widgets/keyword_panel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<String> fullText = ValueNotifier('');
  final ValueNotifier<String> keyword = ValueNotifier('');

  final TriggerInputController _controller = TriggerInputController();
  final ScrollController _suggestionScrollController = ScrollController();

  final suggestions = List.generate(
    50,
    (index) => SuggestionInfo(
      name: faker.person.name(),
      id: faker.guid.guid(),
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller.tfController.baseEntityTextStyle = TextStyle(
        backgroundColor: Colors.amberAccent, fontWeight: FontWeight.bold);

    _controller.tfController.addListener(() {
      fullText.value = _controller.tfController.markupText;
    });
  }

  @override
  void dispose() {
    _suggestionScrollController.dispose();
    super.dispose();
  }

  void _addMention(SuggestionInfo value) {
    _controller.addMention(value);
  }

  void _addTagNameToTextInput() {
    _controller.insertEntityAtStart(
      entity: SuggestionInfo(
        id: faker.guid.guid(),
        name: faker.person.name(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Trigger Input Example',
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Trigger Input Example'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildFullTextPanel(),
              _buildKeywordPanel(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _addTagNameToTextInput,
                  child: const Text('Add Random Mention'),
                ),
              ),
              Expanded(child: _buildSuggestPanel()),
              TriggerInputField(
                controller: _controller,
                initSuggestList: suggestions,
                onKeywordChanged: (newKeyword) => keyword.value = newKeyword,
                decoration: const InputDecoration(
                  hintText: 'Type something...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestPanel() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller.state.suggestionInfos,
        _controller.state.showSuggestions
      ]),
      builder: (_, __) {
        if (_controller.state.suggestionInfos.value.isEmpty ||
            !_controller.state.showSuggestions.value) {
          return Container();
        }
        return Scrollbar(
          controller: _suggestionScrollController,
          child: ListView.builder(
            controller: _suggestionScrollController,
            reverse: true,
            itemCount: _controller.state.suggestionInfos.value.length,
            itemBuilder: (context, index) {
              final details = _controller.state.suggestionInfos.value[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: NetworkImage(
                    'https://api.dicebear.com/7.x/avataaars/png?seed=${details.name}',
                  ),
                ),
                title: Text(
                  details.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle:
                    Text("@${details.name.replaceAll(' ', '_').toLowerCase()}"),
                onTap: () => _addMention(details),
              );
            },
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
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            value,
            style: const TextStyle(
                color: Colors.black, fontFamily: 'monospace', fontSize: 12),
          ),
        );
      },
    );
  }

  Widget _buildKeywordPanel() {
    return ValueListenableBuilder(
      valueListenable: keyword,
      builder: (_, value, __) {
        return KeywordPanel(keyword: value);
      },
    );
  }
}
