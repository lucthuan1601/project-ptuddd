import 'package:flutter/material.dart';

import '../shop_filter.dart';

/// Bộ lọc tìm kiếm, bán kính và sắp xếp tiệm sửa xe & cây xăng (UC-03).
class ShopFilterBar extends StatefulWidget {
  const ShopFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
    required this.selectedRadiusMeters,
    required this.isOpenOnly,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onRadiusChanged,
    required this.onOpenOnlyChanged,
    this.selectedSort = ShopSort.nearest,
    this.onSortChanged,
  });

  final String searchQuery;
  final String? selectedCategory; // null = Tất cả, 'repair_shop', 'gas_station'
  final int selectedRadiusMeters;
  final bool isOpenOnly;
  final ShopSort selectedSort;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<int> onRadiusChanged;
  final ValueChanged<bool> onOpenOnlyChanged;
  final ValueChanged<ShopSort>? onSortChanged;

  @override
  State<ShopFilterBar> createState() => _ShopFilterBarState();
}

class _ShopFilterBarState extends State<ShopFilterBar> {
  late final _controller = TextEditingController(text: widget.searchQuery);

  @override
  void didUpdateWidget(ShopFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.searchQuery,
        selection: TextSelection.collapsed(offset: widget.searchQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ô tìm kiếm theo tên tiệm, chủ tiệm hoặc đường
          TextField(
            controller: _controller,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tìm tên tiệm, chủ tiệm, tên đường...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: widget.searchQuery.isNotEmpty
                  ? IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _controller.clear();
                        widget.onSearchChanged('');
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Hàng lọc danh mục, bán kính, trạng thái mở cửa & sắp xếp
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip(
                  label: 'Tất cả',
                  category: null,
                  icon: Icons.apps,
                ),
                const SizedBox(width: 6),
                _buildCategoryChip(
                  label: 'Tiệm sửa xe',
                  category: 'repair_shop',
                  icon: Icons.build,
                ),
                const SizedBox(width: 6),
                _buildCategoryChip(
                  label: 'Cây xăng',
                  category: 'gas_station',
                  icon: Icons.local_gas_station,
                ),
                const SizedBox(width: 8),
                Container(height: 18, width: 1, color: Colors.grey[300]),
                const SizedBox(width: 8),
                // Bán kính
                ...[1000, 3000, 5000, 10000].map((radius) {
                  final isSelected = widget.selectedRadiusMeters == radius;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text('${radius ~/ 1000} km', style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (_) => widget.onRadiusChanged(radius),
                      selectedColor: const Color(0xFFE3F2FD),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),
                const SizedBox(width: 4),
                // Switch chỉ hiển thị tiệm đang mở
                FilterChip(
                  avatar: Icon(
                    Icons.access_time_filled,
                    size: 16,
                    color: widget.isOpenOnly ? Colors.white : Colors.green[700],
                  ),
                  label: Text(
                    'Đang mở',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isOpenOnly ? Colors.white : Colors.black87,
                      fontWeight: widget.isOpenOnly ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: widget.isOpenOnly,
                  selectedColor: Colors.green[600],
                  checkmarkColor: Colors.white,
                  onSelected: widget.onOpenOnlyChanged,
                  visualDensity: VisualDensity.compact,
                ),
                if (widget.onSortChanged != null) ...[
                  const SizedBox(width: 8),
                  Container(height: 18, width: 1, color: Colors.grey[300]),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    label: 'Gần nhất',
                    sort: ShopSort.nearest,
                    icon: Icons.near_me,
                  ),
                  const SizedBox(width: 6),
                  _buildSortChip(
                    label: 'Đánh giá cao',
                    sort: ShopSort.highestRated,
                    icon: Icons.star_rounded,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required String? category,
    required IconData icon,
  }) {
    final isSelected = widget.selectedCategory == category;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.blueGrey),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => widget.onCategoryChanged(category),
      selectedColor: const Color(0xFF1E88E5),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildSortChip({
    required String label,
    required ShopSort sort,
    required IconData icon,
  }) {
    final isSelected = widget.selectedSort == sort;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : Colors.amber[800],
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => widget.onSortChanged?.call(sort),
      selectedColor: const Color(0xFF1565C0),
      visualDensity: VisualDensity.compact,
    );
  }
}
