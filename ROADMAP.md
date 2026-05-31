# Roadmap

## ✅ Completed

- **Delta Architecture**: Switched to a modern segment-based state management (JSON-friendly) for high performance and easy data sync.
- **Multi-Trigger Support**: Handle `@mentions`, `#hashtags`, `[links]`, and more simultaneously.
- **Keyword Spaces**: Added `allowSpace` option to support trigger keywords with spaces (e.g., @John Doe).
- **Atomic Interaction**: Enhanced tap behavior to automatically select entire entities and trigger context menus.
- **Atomic Entity Deletion**: Mechanism to delete entire mention/entity blocks as single units.
- **Link Replacement**: Automatically converts pasted URLs into interactable text with customizable labels and on/off toggle.
- **Custom Context Menus**: Support for user-defined actions and labels for interactable entities.
- **Data-Driven Testing**: Comprehensive test suite with 40+ cases covering CRUD, IME, and boundary logic.
- **Integration Tests**: End-to-end tests ensuring core features work in real-world scenarios.
- **IME & Vietnamese Support**: Refined handling for complex input methods and diacritics.

## 🚀 Upcoming

- [ ] **Extended Language Support**: Further improvements for RTL languages and complex multi-byte character sets.
- [ ] **Rich Text Formatting**: Extend the Delta architecture to support basic formatting like **bold**, *italic*, and ~~strikethrough~~.
- [ ] **Built-in Suggestion Overlay**: Offer an optional, highly customizable built-in overlay for developers who want a "plug-and-play" experience.
- [ ] **Performance Benchmarking**: Stress testing and optimization for very large documents with thousands of interactive segments.
- [ ] **Documentation Site**: Create a dedicated documentation site with interactive examples and integration guides.
