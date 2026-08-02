import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String slug,
    required String name,
    required String shortDescription,
    required String description,
    required Map<String, String> specifications,
    required List<String> images,
    required double price,
    required String sku,
    required String categoryId,
    required int stockQuantity,
    required double rating,
    required int reviewCount,
    required DateTime createdAt,
    String? videoUrl,
    double? compareAtPrice,
    @Default([]) List<ProductVariant> variants,
    @Default(false) bool isFeatured,
    @Default(false) bool isNew,
  }) = _Product;

  const Product._();

  bool get inStock => stockQuantity > 0;

  bool get hasDiscount => compareAtPrice != null && compareAtPrice! > price;

  double? get discountPercent =>
      hasDiscount ? ((compareAtPrice! - price) / compareAtPrice! * 100) : null;

  String get primaryImage => images.isNotEmpty ? images.first : '';
}

@freezed
abstract class ProductVariant with _$ProductVariant {
  const factory ProductVariant({
    required String id,
    required String label,
    String? imageUrl,
    double? priceOverride,
    @Default(true) bool inStock,
  }) = _ProductVariant;
}
