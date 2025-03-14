class SuggestionController {
  final List<String> suggestions;

  SuggestionController({required this.suggestions});

  updateSuggestions(List<String> newSuggestions) {
    suggestions.clear();
    suggestions.addAll(newSuggestions);
  }

  List<String> filter(String query) {
    return suggestions
        .where((s) => s.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
