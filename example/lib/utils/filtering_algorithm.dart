import 'package:flutter_trigger_input/extensions/string_ext.dart';
import 'package:flutter_trigger_input/flutter_trigger_input.dart';

class FilteringAlgorithm {
  List<SuggestionInfo> execute(
    String trigger,
    String keyword,
    List<SuggestionInfo> suggestionInfos,
    List<SuggestionInfo> newCanMentions,
  ) {
    final normalizedKeyword = keyword.trim().toLowerCase();

    final canMentions = newCanMentions;

    List<SuggestionInfo> currentSuggestions = suggestionInfos;
    currentSuggestions.clear();

    if (_shouldReturnEmpty(canMentions, keyword, normalizedKeyword)) {
      return currentSuggestions;
    }

    final baseSuggestions = [...canMentions]..removeAt(0);

    final filteredSuggestions =
        _filterSuggestions(baseSuggestions, normalizedKeyword);

    final uniqueSuggestions = _uniqueSuggestions(filteredSuggestions);

    final scoredSuggestions = normalizedKeyword.isEmpty
        ? [...uniqueSuggestions]
        : _scoreSuggestions(uniqueSuggestions, normalizedKeyword);

    scoredSuggestions.sort((a, b) => b.score - a.score);

    if (scoredSuggestions.isEmpty) {
      scoredSuggestions.clear();
      currentSuggestions.clear();
    } else {
      currentSuggestions = scoredSuggestions;
    }

    return currentSuggestions;
  }

  bool _shouldReturnEmpty(
    List<SuggestionInfo> canMentions,
    String rawKeyword,
    String normalizedKeyword,
  ) {
    return canMentions.isEmpty ||
        (rawKeyword.isNotEmpty &&
            (normalizedKeyword.isEmpty || rawKeyword.contains('\n')));
  }

  List<SuggestionInfo> _filterSuggestions(
    List<SuggestionInfo> mentions,
    String normalizedKeyword,
  ) {
    if (normalizedKeyword.isEmpty) return mentions;

    final cleanKeyword = normalizedKeyword.removeVietnameseAccent();
    return mentions
        .where(
          (member) => member.suggestionName
              .removeVietnameseAccent()
              .toLowerCase()
              .contains(cleanKeyword),
        )
        .toList();
  }

  List<SuggestionInfo> _uniqueSuggestions(List<SuggestionInfo> mentions) {
    final seenIds = <String>{};
    final result = <SuggestionInfo>[];

    for (final member in mentions) {
      if (seenIds.add(member.id)) {
        member.name = member.suggestionName.removeVietnameseAccent();
        result.add(member);
      }
    }

    return result;
  }

  List<SuggestionInfo> _scoreSuggestions(
    List<SuggestionInfo> mentions,
    String normalizedKeyword,
  ) {
    final cleanQuery = normalizedKeyword.removeVietnameseAccent();
    final queryParts = cleanQuery.split(' ');

    for (final member in mentions) {
      final (firstName, midName, lastName) = _splitName(member.name);
      var score = 0;

      for (final query in queryParts) {
        if (firstName.contains(query)) {
          score += 10000;
          if (firstName.removeVietnameseAccent() == cleanQuery) {
            score += 10000;
          }
        }
        if (midName.contains(query)) {
          score += 500;
          if (midName.removeVietnameseAccent() == cleanQuery) {
            score += 200;
          }
        }
        if (lastName.contains(query)) {
          score += 100;
          if (lastName.removeVietnameseAccent() == cleanQuery) {
            score += 100;
          }
        }
      }

      member.score = score;
    }

    return mentions;
  }

  (String firstName, String midName, String lastName) _splitName(String name) {
    final parts = name.split(' ');
    if (parts.length == 1) {
      return (parts.first, '', parts.last);
    }
    if (parts.length == 2) {
      return (parts[1], '', parts.first);
    }

    return (
      parts.last,
      parts.sublist(1, parts.length - 1).join(' '),
      parts.first,
    );
  }
}
