import 'dart:convert';

import 'package:hive/hive.dart';

class SearchHistoryRepository {
  SearchHistoryRepository(this._box);

  final Box<String> _box;

  static const _key = 'history';
  static const _maxEntries = 10;

  List<String> getHistory() {
    final raw = _box.get(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<void> addTerm(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    final history = getHistory()
      ..removeWhere((t) => t.toLowerCase() == trimmed.toLowerCase())
      ..insert(0, trimmed);
    if (history.length > _maxEntries) {
      history.removeRange(_maxEntries, history.length);
    }
    await _box.put(_key, jsonEncode(history));
  }

  Future<void> clear() => _box.delete(_key);
}
