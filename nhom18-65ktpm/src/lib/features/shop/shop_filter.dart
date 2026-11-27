import '../../models/shop.dart';

/// Lọc danh sách tiệm theo từ khóa tên tiệm hoặc địa chỉ (UC-03).
List<Shop> filterShops(List<Shop> shops, String query) {
  final normalized = query.toLowerCase().trim();
  if (normalized.isEmpty) return shops;
  return shops
      .where(
        (s) =>
            s.name.toLowerCase().contains(normalized) ||
            s.address.toLowerCase().contains(normalized),
      )
      .toList();
}
