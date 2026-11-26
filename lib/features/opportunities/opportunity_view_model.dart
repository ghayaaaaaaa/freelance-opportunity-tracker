import 'package:flutter/foundation.dart';

import '../../data/opportunity_repository.dart';
import '../../domain/opportunity.dart';

class OpportunityViewModel extends ChangeNotifier {
  OpportunityViewModel(this._repository) {
    load();
  }

  final OpportunityRepository _repository;
  final List<Opportunity> _opportunities = [];
  bool isLoading = true;
  String? errorMessage;
  String query = '';
  String activeFilter = 'All';

  int get totalCount => _opportunities.length;

  int countForStatus(OpportunityStatus status) => _opportunities
      .where((opportunity) => opportunity.status == status)
      .length;

  int countForFilter(String filter) {
    if (filter == 'All') return totalCount;
    for (final status in OpportunityStatus.values) {
      if (status.label == filter) return countForStatus(status);
    }
    return 0;
  }

  List<Opportunity> get visibleOpportunities {
    final normalizedQuery = query.trim().toLowerCase();
    return _opportunities.where((opportunity) {
      final matchesFilter =
          activeFilter == 'All' || opportunity.status.label == activeFilter;
      final searchable = [
        opportunity.title,
        opportunity.platform,
        opportunity.budget,
        opportunity.url,
        opportunity.notes,
      ].join(' ').toLowerCase();
      return matchesFilter &&
          (normalizedQuery.isEmpty || searchable.contains(normalizedQuery));
    }).toList()
      ..sort((first, second) => second.createdAt.compareTo(first.createdAt));
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      _opportunities
        ..clear()
        ..addAll(await _repository.loadAll());
    } catch (_) {
      errorMessage =
          'Saved records could not be read. Check device storage and retry.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void setFilter(String value) {
    activeFilter = value;
    notifyListeners();
  }

  Future<bool> add(Opportunity opportunity) async {
    final previous = List<Opportunity>.of(_opportunities);
    _opportunities.add(opportunity);
    return _persist(previous);
  }

  Future<bool> update(Opportunity opportunity) async {
    final index =
        _opportunities.indexWhere((item) => item.id == opportunity.id);
    if (index < 0) return false;
    final previous = List<Opportunity>.of(_opportunities);
    _opportunities[index] = opportunity;
    return _persist(previous);
  }

  Future<bool> remove(String id) async {
    final previous = List<Opportunity>.of(_opportunities);
    _opportunities.removeWhere((item) => item.id == id);
    return _persist(previous);
  }

  Future<bool> setStatus(Opportunity opportunity, OpportunityStatus status) {
    return update(opportunity.copyWith(status: status));
  }

  Future<bool> _persist(List<Opportunity> previous) async {
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.saveAll(_opportunities);
      notifyListeners();
      return true;
    } catch (_) {
      _opportunities
        ..clear()
        ..addAll(previous);
      errorMessage = 'Changes could not be saved on this device.';
      notifyListeners();
      return false;
    }
  }
}
