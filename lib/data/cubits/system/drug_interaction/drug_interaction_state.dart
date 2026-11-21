class DrugInteractionState {
  final Map<String, String> selected; // drugbank_id -> display name
  final List<Map<String, dynamic>> results;
  final bool hasSearched;

  const DrugInteractionState({
    this.selected = const {},
    this.results = const [],
    this.hasSearched = false,
  });

  DrugInteractionState copyWith({
    Map<String, String>? selected,
    List<Map<String, dynamic>>? results,
    bool? hasSearched,
  }) {
    return DrugInteractionState(
      selected: selected ?? this.selected,
      results: results ?? this.results,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}
