import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/di/injector.dart';
import 'package:naqirgiftbox/core/error/failures.dart';
import 'package:naqirgiftbox/features/categories/domain/entities/category.dart';
import 'package:naqirgiftbox/features/categories/domain/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => getIt<CategoryRepository>(),
);

/// All categories, loaded once and cached for the session (categories change
/// rarely — screens that need a fresh copy can `ref.invalidate` this).
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final result = await repository.getCategories();
  return result.when(
    success: (data) => data,
    failure: (failure) => throw failure,
  );
});

final categoryByIdProvider = FutureProvider.family<Category, String>((
  ref,
  id,
) async {
  final categories = await ref.watch(categoriesProvider.future);
  return categories.firstWhere(
    (c) => c.id == id,
    orElse: () => throw const NotFoundFailure('Category not found.'),
  );
});
