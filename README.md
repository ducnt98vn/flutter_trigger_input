# flutter_trigger_input

<div align="center">
  <img src="https://github.com/ducnt98vn/flutter_trigger_input/blob/main/screenshots/demo.png?raw=true" 
       alt="A screenshot of the iOS example app" 
       width="240"/>
</div>

A highly customizable Flutter widget for detecting and handling interactive triggers like mentions, hashtags, and links within a text field.

## 🧠 The Core Algorithm: Delta Architecture

This package has undergone a major core engine upgrade, moving away from traditional **string-based manual offset calculations** and Regex-based sync logic to a modern **Delta Architecture**.

### Why Delta?
- **Segment-based Management**: Instead of one long string, content is managed as a list of structured segments (Plain Text, Mentions, Links).
- **High Performance**: Only affected segments are updated during edits, avoiding expensive recalculations of the entire text field.
- **Data Integrity**: Special entities (like mentions) are treated as atomic units, preventing accidental partial modifications.
- **Backend Friendly**: Content is exported as a structured JSON array (Quill-like Delta format), making it easy to store and render across different platforms.

## 🚀 Key Features

- **Multi-Trigger Support**: Handle `@mentions`, `#hashtags`, `[links]`, and more simultaneously.
- **Delta Architecture**: Manages content as structured segments (JSON), perfect for backend storage.
- **Keyword Spaces**: Support for triggers with spaces (e.g., `@John Doe`) via `allowSpace: true`.
- **Atomic Deletion**: Entities are deleted as single units.
- **Auto Link Replacement**: Automatically converts pasted URLs into interactable text.
- **Custom Context Menus**: Define custom actions for each trigger type.

## 🛠 Usage

### 1. Initialize the Controller
Define your triggers and their respective styles.

```dart
final _controller = TriggerInputController<SuggestionInfo>(
  triggers: [
    Mention(
      trigger: '@',
      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
    ),
    Mention(
      trigger: '#',
      style: const TextStyle(color: Colors.pink),
    ),
  ],
);
```

### 2. Add the Widget
```dart
TriggerInputField<SuggestionInfo>(
  controller: _controller,
  allowSpace: true,
  onMentionSearchChanged: (trigger, keyword) {
    // Fetch and update suggestions in your state
    final results = mySearchLogic(trigger, keyword);
    _controller.state.suggestionInfos.value = results;
  },
)
```

### 3. Get Structured Data
Access the content in a structured JSON format (Delta) for your API.
```dart
String jsonMarkup = _controller.tfController.markupText;
// Output: [{"insert": "Hi "}, {"insert": "@John", "attributes": {"mention": {"id": "1"}}}]
```

## 📝 Credits
- [bbob_dart](https://pub.dev/packages/bbob_dart)

## 🤝 Issues and feedback
Feel free to open a Github issue for suggestions or bug reports.
