import 'package:naqirgiftbox/core/config/app_config.dart';
import 'package:naqirgiftbox/core/error/exceptions.dart';
import 'package:naqirgiftbox/core/error/failures.dart';
import 'package:naqirgiftbox/core/error/result.dart';
import 'package:naqirgiftbox/features/products/data/datasources/product_data_source.dart';
import 'package:naqirgiftbox/features/products/data/models/product_dto.dart';
import 'package:naqirgiftbox/features/products/domain/entities/paginated_products.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product_query.dart';
import 'package:naqirgiftbox/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required AppConfig config,
    required ProductDataSource remoteDataSource,
    required ProductDataSource mockDataSource,
  }) : _config = config,
       _remoteDataSource = remoteDataSource,
       _mockDataSource = mockDataSource;

  final AppConfig _config;
  final ProductDataSource _remoteDataSource;
  final ProductDataSource _mockDataSource;

  ProductDataSource get _dataSource =>
      _config.useMockData ? _mockDataSource : _remoteDataSource;

  @override
  Future<Result<PaginatedProducts>> getProducts(ProductQuery query) async {
    try {
      final result = await _dataSource.getProducts(query);
      final hasMore = query.page * query.pageSize < result.totalCount;
      return Result.success(
        PaginatedProducts(
          items: result.items.map((dto) => dto.toEntity()).toList(),
          totalCount: result.totalCount,
          page: query.page,
          hasMore: hasMore,
        ),
      );
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<Product>> getProduct(String id) async {
    try {
      final ProductDto dto = await _dataSource.getProduct(id);
      return Result.success(dto.toEntity());
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<List<Product>>> getRelatedProducts(
    String productId, {
    int limit = 10,
  }) async {
    try {
      final dtos = await _dataSource.getRelatedProducts(
        productId,
        limit: limit,
      );
      return Result.success(dtos.map((dto) => dto.toEntity()).toList());
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }
}
