import '../../../core/supabase_client.dart';
import '../../../models/review.dart';
import '../../../repositories/review_repository.dart';

/// Triển khai ReviewRepository qua Supabase REST API (UC-04).
class SupabaseReviewRepository implements ReviewRepository {
  @override
  Future<List<Review>> listByShop(String shopId) async {
    final res = await supabase
        .from('reviews')
        .select()
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => Review.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<Review> upsert({
    required String shopId,
    required int rating,
    String? comment,
  }) async {
    throw UnimplementedError('Sẽ triển khai trong UC-08');
  }
}
