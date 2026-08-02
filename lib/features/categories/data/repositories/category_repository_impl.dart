import 'package:naqirgiftbox/core/config/app_config.dart';
import 'package:naqirgiftbox/core/error/exceptions.dart';
import 'package:naqirgiftbox/core/error/failures.dart';
import 'package:naqirgiftbox/core/error/result.dart';
import 'package:naqirgiftbox/features/categories/data/datasources/category_data_source.dart';
import 'package:naqirgiftbox/features/categories/data/models/category_dto.dart';
import 'package:naqirgiftbox/features/categories/domain/entities/category.dart';
import 'package:naqirgiftbox/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({
    required AppConfig config,
    required CategoryDataSource remoteDataSource,
    required CategoryDataSource mockDataSource,
  }) : _config = config,
       _remoteDataSource = remoteDataSource,
       _mockDataSource = mockDataSource;

  final AppConfig _config;
  final CategoryDataSource _remoteDataSource;
  final CategoryDataSource _mockDataSource;

  CategoryDataSource get _dataSource =>
      _config.useMockData ? _mockDataSource : _remoteDataSource;

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final dtos = await _dataSource.getCategories();
      return Result.success(dtos.map((dto) => dto.toEntity()).toList());
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<Category>> getCategory(String id) async {
    try {
      final dto = await _dataSource.getCategory(id);
      return Result.success(dto.toEntity());
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }
}
