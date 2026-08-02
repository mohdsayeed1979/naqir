import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';

part 'product_dto.freezed.dart';
part 'product_dto.g.dart';

/// Wire format for the generic REST contract (see docs/ARCHITECTURE.md §1).
/// Kept separate from [Product] so a real backend's field names/shape can
/// change without touching domain or presentation code.
@freezed
abstract class ProductDto with _$ProductDto {
  const factory ProductDto({
    required String id,
    required String slug,
    required String name,
    @JsonKey(name: 'short_description') required String shortDescription,
    required String description,
    required Map<String, String> specifications,
    required List<String> images,
    required double price,
    required String sku,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'stock_quantity') required int stockQuantity,
    required double rating,
    @JsonKey(name: 'review_count') required int reviewCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'video_url') String? videoUrl,
    @JsonKey(name: 'compare_at_price') double? compareAtPrice,
    @Default([]) List<ProductVariantDto> variants,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'is_new') @Default(false) bool isNew,
  }) = _ProductDto;

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);
}

@freezed
abstract class ProductVariantDto with _$ProductVariantDto {
  const factory ProductVariantDto({
    required String id,
    required String label,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'price_override') double? priceOverride,
    @JsonKey(name: 'in_stock') @Default(true) bool inStock,
  }) = _ProductVariantDto;

  factory ProductVariantDto.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantDtoFromJson(json);
}

extension ProductDtoMapper on ProductDto {
  Product toEntity() => Product(
    id: id,
    slug: slug,
    name: name,
    shortDescription: shortDescription,
    description: description,
    specifications: specifications,
    images: images,
    price: price,
    sku: sku,
    categoryId: categoryId,
    stockQuantity: stockQuantity,
    rating: rating,
    reviewCount: reviewCount,
    createdAt: createdAt,
    videoUrl: videoUrl,
    compareAtPrice: compareAtPrice,
    variants: variants.map((v) => v.toEntity()).toList(),
    isFeatured: isFeatured,
    isNew: isNew,
  );
}

extension ProductVariantDtoMapper on ProductVariantDto {
  ProductVariant toEntity() => ProductVariant(
    id: id,
    label: label,
    imageUrl: imageUrl,
    priceOverride: priceOverride,
    inStock: inStock,
  );
}
