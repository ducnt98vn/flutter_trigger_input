import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
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
      Future.microtask(() {
        fullText.value = _controller.tfController.markupText;
      });
    });
  }

  @override
  void dispose() {
    _suggestionScrollController.dispose();
    super.dispose();
  }

  void _addMention(SuggestionInfo value) {
    _controller.state.suggestionInfos.value = [];
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

  List<SuggestionInfo> onMentionSearchChanged(String trigger, String keyword) {
    triggeredKey.value = '$trigger$keyword';

    return FilteringAlgorithm().execute(
      trigger,
      keyword,
      _controller.state.suggestionInfos.value,
      _controller.state.canMentions.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Trigger Input'),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _addTagNameToTextInput,
                        child: const Text('Add Random Mention'),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Flexible(child: _buildSuggestPanel())],
              ),
            ],
          )),
          TriggerInputField<SuggestionInfo>(
            controller: _controller,
            initSuggestList: suggestions,
            decoration: const InputDecoration(
              hintText: 'Type something...',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 4,
            onMentionSearchChanged: onMentionSearchChanged,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSuggestPanel() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller.state.suggestionInfos,
      ]),
      builder: (_, __) {
        if (_controller.state.suggestionInfos.value.isEmpty) {
          return SizedBox.shrink();
        }
        return Scrollbar(
          controller: _suggestionScrollController,
          child: ListView.builder(
            controller: _suggestionScrollController,
            reverse: true,
            itemCount: _controller.state.suggestionInfos.value.length,
            itemBuilder: (context, index) {
              final details = _controller.state.suggestionInfos.value[index];

              return Container(
                color: Colors.white,
                child: ListTile(
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
                  subtitle: Text(
                      "@${details.name.replaceAll(' ', '_').toLowerCase()}"),
                  onTap: () => _addMention(details),
                  // onTap: () => _addMention(details),
                ),
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
          height: 200,
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
      valueListenable: triggeredKey,
      builder: (_, value, __) {
        return KeywordPanel(keyword: value);
      },
    );
  }
}
