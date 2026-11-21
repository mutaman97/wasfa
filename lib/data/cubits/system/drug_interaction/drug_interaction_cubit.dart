import 'package:flutter_bloc/flutter_bloc.dart';

import 'drug_interaction_state.dart';

class DrugInteractionCubit extends Cubit<DrugInteractionState> {
  DrugInteractionCubit() : super(const DrugInteractionState());

  void addDrug(String id, String name) {
    final updated = Map<String, String>.from(state.selected);
    updated[id] = name;
    emit(state.copyWith(selected: updated));
  }

  void removeDrug(String id) {
    final updated = Map<String, String>.from(state.selected)..remove(id);
    emit(state.copyWith(selected: updated));
  }

  void clearResults() {
    emit(state.copyWith(results: const [], hasSearched: false));
  }

  void setResults(List<Map<String, dynamic>> rows) {
    emit(state.copyWith(results: rows, hasSearched: true));
  }
}
