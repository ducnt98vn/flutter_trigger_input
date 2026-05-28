# flutter_trigger_input

<div align="center">
  <img src="https://github.com/ducnt98vn/flutter_trigger_input/blob/main/screenshots/demo.png?raw=true" 
       alt="A screenshot of the iOS example app" 
       width="300"/>
</div>

A highly customizable Flutter widget for detecting and handling interactive triggers like mentions, hashtags, and links within a text field. It offers a seamless way to manage suggestion overlays with full generic type support and built-in markup parsing.

## Getting Started

To get a clear understanding of how this package works in a real-world scenario, we highly recommend checking out the included example.

> **Note**: Run the example project to see the full implementation in action.

## 🚀 Usage

Follow these steps to integrate Flutter Trigger Input into your project:

**1. Initialize the Controller**

Create an instance of TriggerInputController. This controller manages the detection logic and the state of your input field.

```dart
final TriggerInputController _controller = TriggerInputController();
```

**2. Add the TriggerInputField Widget**

Place the TriggerInputField in your widget tree. Pass the \_controller and your initial list of suggestions (initSuggestList). This widget automatically detects trigger characters (like @) as the user types.

```dart
TriggerInputField(
  controller: _controller,
  initSuggestList: suggestions, // Your list of SuggestionInfo objects
  onMentionSearchChanged: onMentionSearchChanged,
),
```

**3. Listen for Suggestions**

To display a custom suggestion UI (like a ListView above the keyboard), listen to the suggestionInfos notifier. It updates in real-time based on the user's search keyword.

```dart
ValueListenableBuilder<List<SuggestionInfo>>(
  valueListenable: _controller.suggestionInfos,
  builder: (context, suggestions, child) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return MySuggestionList(items: suggestions);
  },
)
```

## Credits 👨‍💻

- [bbob_dart](https://pub.dev/packages/bbob_dart)
- [flutter_quill](https://pub.dev/packages/flutter_quill)

## Issues and feedback 💭

If you have any suggestion for including a feature or if something doesn't work, feel free to open a Github issue for us to have a discussion on it.
