## 0.4.0

- **Core Engine Upgrade**: Switched from a string-based manual offset calculation algorithm to a modern **Delta Architecture** (Segment-based state management). This significantly improves performance and provides JSON-friendly data for easy backend synchronization.
- **Link Replacement**: Automatically converts pasted URLs into interactable text with customizable labels.
- **Custom Context Menus**: Added support for custom actions and labels in the context menu for mentions and hashtags.
- **Atomic Interaction**: Enhanced tap behavior to automatically select entire entities.
- **Debounce Support**: Moved search debouncing to the user side for better flexibility with async operations.
- **Cleanup**: Removed outdated BBCode dependencies and simplified the core engine.

## 0.3.0

- **Multi-Trigger Support**: Support multiple triggers simultaneously (e.g., @mentions, #hashtags).
- **Keyword Spaces**: Added `allowSpace` option to support trigger keywords with spaces (e.g., @Full Name).
- **Enhanced Core Engine**: Optimized `MentionTextRenderer` for improved efficiency and accurate state synchronization.

## 0.2.0

- **Atomic Entity Deletion**: Implement a mechanism to delete the entire mention/entity
- **User-defined filtering algorithm**.

## 0.1.2

- Update example

## 0.1.1

- **Fix**: Added missing generated files (`.g.dart`) to the package distribution to resolve compilation errors.

## 0.1.0

- Initial release
