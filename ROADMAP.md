# Roadmap

## ✅ Completed

- **Multi-Trigger Support**: Support multiple triggers simultaneously (e.g., @mentions, #hashtags, [links]).
- **Keyword Spaces**: Added `allowSpace` option to support trigger keywords with spaces (e.g., @Full Name).
- **Atomic Entity Deletion**: Mechanism to delete the entire mention/entity block when any part of it is modified.
- **Enhanced Core Engine**: Optimized `MentionTextRenderer` for improved efficiency and accurate state synchronization.
- **IME & Vietnamese Support**: Refined handling for complex input methods and diacritics.
- **User-defined Filtering**: Customizable algorithm for suggestion filtering and scoring.
- **Data-Driven Testing**: Comprehensive test suite covering edge cases, CRUD operations, and boundary logic.
- **Custom Markup**: Support for custom BBCode through `markupBuilder`.

## 🚀 Upcoming

- [ ] **Copy Raw Mention**: Provide additional options in the context menu to copy the raw markup/BBCode of a mention.
- [ ] **Advanced BBCode Customization**: More flexible tag parsing beyond standard [mention] and [link].
- [ ] **Integration Tests**: Basic integration tests for real-world usage scenarios.
- [ ] **Extended Language Support**: Further improvements for RTL languages and complex character sets.
- [ ] **Context Menu Customization**: Allow users to define custom actions for mentioned entities.
