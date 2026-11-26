import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/opportunity.dart';

abstract class OpportunityRepository {
  Future<List<Opportunity>> loadAll();
  Future<void> saveAll(List<Opportunity> opportunities);
}

class PreferencesOpportunityRepository implements OpportunityRepository {
  static const _storageKey = 'freelance_opportunities_v1';

  @override
  Future<List<Opportunity>> loadAll() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null || encoded.isEmpty) return const [];

    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      throw const FormatException('Stored opportunities must be a JSON list.');
    }
    return decoded
        .map((value) => Opportunity.fromJson(value as Map<String, dynamic>))
        .toList(growable: true);
  }

  @override
  Future<void> saveAll(List<Opportunity> opportunities) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(opportunities.map((value) => value.toJson()).toList());
    final saved = await preferences.setString(_storageKey, encoded);
    if (!saved) {
      throw StateError('The device could not save the opportunity list.');
    }
  }
}

