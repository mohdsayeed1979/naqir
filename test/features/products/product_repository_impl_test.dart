import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:naqirgiftbox/core/config/app_config.dart';
import 'package:naqirgiftbox/core/error/exceptions.dart';
import 'package:naqirgiftbox/core/error/failures.dart';
import 'package:naqirgiftbox/features/products/data/datasources/product_data_source.dart';
import 'package:naqirgiftbox/features/products/data/models/product_dto.dart';
import 'package:naqirgiftbox/features/products/data/repositories/product_repository_impl.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product_query.dart';

class MockProductDataSource extends Mock implements ProductDataSource {}

ProductDto _buildDto({String id = 'p-1'}) {
  return ProductDto(
    id: id,
    slug: 'slug-$id',
    name: 'Product $id',
    shortDescription: 'short',
    description: 'description',
    specifications: const {},
    images: const [],
    price: 100,
    sku: 'SKU-$id',
    categoryId: 'cat-1',
    stockQuantity: 5,
    rating: 4.2,
    reviewCount: 10,
    createdAt: DateTime(2026),
  );
}

void main() {
  late MockProductDataSource mockDataSource;
  late MockProductDataSource remoteDataSource;
  late ProductRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const ProductQuery());
  });

  setUp(() {
    mockDataSource = MockProductDataSource();
    remoteDataSource = MockProductDataSource();
    repository = ProductRepositoryImpl(
      config: const AppConfig(
        flavor: Flavor.mock,
        apiBaseUrl: 'https://example.test',
        enableRequestLogging: false,
      ),
      remoteDataSource: remoteDataSource,
      mockDataSource: mockDataSource,
    );
  });

  test('getProducts uses the mock data source when flavor is mock', () async {
    when(
      () => mockDataSource.getProducts(any()),
    ).thenAnswer((_) async => (items: [_buildDto()], totalCount: 1));

    final result = await repository.getProducts(const ProductQuery());

    result.when(
      success: (data) {
        expect(data.items, hasLength(1));
        expect(data.totalCount, 1);
        expect(data.hasMore, isFalse);
      },
      failure: (_) => fail('expected success'),
    );
    verifyNever(() => remoteDataSource.getProducts(any()));
  });

  test('getProducts reports hasMore when more pages remain', () async {
    when(
      () => mockDataSource.getProducts(any()),
    ).thenAnswer((_) async => (items: [_buildDto()], totalCount: 50));

    final result = await repository.getProducts(
      const ProductQuery(page: 1, pageSize: 20),
    );

    result.when(
      success: (data) => expect(data.hasMore, isTrue),
      failure: (_) => fail('expected success'),
    );
  });

  test('getProduct maps a NotFoundException to a NotFoundFailure', () async {
    when(
      () => mockDataSource.getProduct(any()),
    ).thenThrow(const NotFoundException('missing'));

    final result = await repository.getProduct('missing-id');

    result.when(
      success: (_) => fail('expected failure'),
      failure: (failure) => expect(failure, isA<NotFoundFailure>()),
    );
  });

  test(
    'getProduct maps an unexpected error to UnknownFailure rather than crashing',
    () async {
      when(
        () => mockDataSource.getProduct(any()),
      ).thenThrow(StateError('boom'));

      final result = await repository.getProduct('any-id');

      result.when(
        success: (_) => fail('expected failure'),
        failure: (failure) => expect(failure, isA<UnknownFailure>()),
      );
    },
  );
}
