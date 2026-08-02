import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:naqirgiftbox/features/categories/domain/entities/category.dart';

part 'category_dto.freezed.dart';
part 'category_dto.g.dart';

@freezed
abstract class CategoryDto with _$CategoryDto {
  const factory CategoryDto({
    required String id,
    required String name,
    required String slug,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'parent_id') String? parentId,
  }) = _CategoryDto;

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);
}

extension CategoryDtoMapper on CategoryDto {
  Category toEntity() => Category(
    id: id,
    name: name,
    slug: slug,
    imageUrl: imageUrl,
    parentId: parentId,
  );
}
