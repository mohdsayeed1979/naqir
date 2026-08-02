import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';
import 'package:naqirgiftbox/features/search/data/search_history_repository.dart';

const trendingSearches = [
  'Gift Box',
  'Dates Tray',
  'Chocolate',
  'Oud & Bakhoor',
  'Wedding Favors',
];

final searchHistoryRepositoryProvider = Provider<SearchHistoryRepository>(
  (ref) => SearchHistoryRepository(HiveBoxes.searchHistory),
);

class SearchHistoryNotifier extends Notifier<List<String>> {
  late SearchHistoryRepository _repository;

  @override
  List<String> build() {
    _repository = ref.watch(searchHistoryRepositoryProvider);
    return _repository.getHistory();
  }

  Future<void> addTerm(String term) async {
    await _repository.addTerm(term);
    state = _repository.getHistory();
  }

  Future<void> clear() async {
    await _repository.clear();
    state = [];
  }
}

final searchHistoryProvider =
    NotifierProvider<SearchHistoryNotifier, List<String>>(
      SearchHistoryNotifier.new,
    );
