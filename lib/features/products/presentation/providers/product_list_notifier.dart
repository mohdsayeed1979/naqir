import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product_query.dart';
import 'package:naqirgiftbox/features/products/domain/repositories/product_repository.dart';
import 'package:naqirgiftbox/features/products/presentation/providers/product_list_state.dart';
import 'package:naqirgiftbox/features/products/presentation/providers/product_providers.dart';

/// Drives any paginated/filterable product grid — "All Products", a
/// category's listing, and search results all use the same notifier, seeded
/// with a different initial [ProductQuery] via the family argument.
class ProductListNotifier
    extends FamilyNotifier<ProductListState, ProductQuery> {
  late ProductRepository _repository;

  @override
  ProductListState build(ProductQuery arg) {
    _repository = ref.watch(productRepositoryProvider);
    Future.microtask(_loadFirstPage);
    return ProductListState(query: arg);
  }

  Future<void> refresh() => _loadFirstPage();

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.query.page + 1;
    final result = await _repository.getProducts(
      state.query.copyWith(page: nextPage),
    );
    state = result.when(
      success: (data) => state.copyWith(
        items: [...state.items, ...data.items],
        totalCount: data.totalCount,
        hasMore: data.hasMore,
        isLoadingMore: false,
        query: state.query.copyWith(page: nextPage),
      ),
      failure: (failure) =>
          state.copyWith(isLoadingMore: false, failure: failure),
    );
  }

  Future<void> updateSort(ProductSortOption sort) async {
    state = state.copyWith(query: state.query.copyWith(sort: sort, page: 1));
    await _loadFirstPage();
  }

  Future<void> applyFilters(
    ProductQuery Function(ProductQuery current) update,
  ) async {
    state = state.copyWith(query: update(state.query).copyWith(page: 1));
    await _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    state = state.copyWith(isLoading: true, failure: null);
    final result = await _repository.getProducts(state.query.copyWith(page: 1));
    state = result.when(
      success: (data) => state.copyWith(
        items: data.items,
        totalCount: data.totalCount,
        hasMore: data.hasMore,
        isLoading: false,
        query: state.query.copyWith(page: 1),
      ),
      failure: (failure) => state.copyWith(isLoading: false, failure: failure),
    );
  }
}

final productListProvider =
    NotifierProvider.family<
      ProductListNotifier,
      ProductListState,
      ProductQuery
    >(ProductListNotifier.new);
