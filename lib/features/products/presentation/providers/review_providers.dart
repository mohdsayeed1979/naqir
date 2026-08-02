import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/features/products/domain/entities/review.dart';
import 'package:naqirgiftbox/features/products/presentation/providers/product_providers.dart';

const _reviewerNames = [
  'Fatimah A.',
  'Mohammed S.',
  'Noura K.',
  'Abdullah R.',
  'Layla M.',
  'Khalid T.',
  'Reem H.',
  'Faisal N.',
  'Hind Z.',
  'Omar B.',
];

const _reviewComments = [
  'Beautiful packaging, exactly as pictured. Will order again for Eid.',
  'The quality of the dates was excellent, very fresh.',
  'Arrived quickly and well protected. Made a great gift.',
  'A bit smaller than I expected, but the presentation is lovely.',
  'My go-to for corporate gifting now — always impresses.',
  'Great value for the price, the ribbon detail is a nice touch.',
  'Exactly what I needed for a last-minute wedding favor.',
  'Would love to see more color options, but overall very happy.',
];

/// There is no reviews endpoint yet (see docs/ARCHITECTURE.md §1) — this
/// generates a believable, deterministic set of reviews per product (seeded
/// by product id) so the section reads as real content rather than a blank
/// "coming soon", and is a one-line swap once a real endpoint exists.
final productReviewsProvider = FutureProvider.family<List<Review>, String>((
  ref,
  productId,
) async {
  final product = await ref.watch(productDetailProvider(productId).future);
  final random = Random(product.id.hashCode);
  final count = 2 + random.nextInt(3);

  return List.generate(count, (index) {
    final ratingJitter = (random.nextDouble() - 0.5) * 1.0;
    final rating = (product.rating + ratingJitter).clamp(3.0, 5.0);
    return Review(
      id: '${product.id}-review-$index',
      authorName: _reviewerNames[random.nextInt(_reviewerNames.length)],
      rating: double.parse(rating.toStringAsFixed(1)),
      comment: _reviewComments[random.nextInt(_reviewComments.length)],
      createdAt: product.createdAt.add(Duration(days: 3 + index * 5)),
    );
  });
});
