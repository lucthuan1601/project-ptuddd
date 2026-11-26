import 'package:flutter/material.dart';

import '../../features/owner/data/owner_shop_repository.dart';
import '../../features/owner/screens/shop_editor_screen.dart';
import '../../models/shop.dart';
import '../../repositories/auth_repository.dart';

/// Màn hình danh sách tiệm của Owner trong UC-09.
/// UC-11 sẽ bổ sung công tắc đóng/mở cửa và UC-12 sẽ gắn SOS của Tùng.
class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});

  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  final _repository = OwnerShopRepository();
  late Future<List<Shop>> _shops;

  @override
  void initState() {
    super.initState();
    _shops = _repository.myShops();
  }

  Future<void> _reload() async {
    final future = _repository.myShops();
    setState(() => _shops = future);
    try {
      await future;
    } catch (_) {
      // FutureBuilder sẽ hiển thị lỗi để người dùng thử lại.
    }
  }

  Future<void> _openForm([Shop? shop]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ShopEditorScreen(shop: shop)),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          shop == null
              ? 'Đã đăng ký tiệm. Vui lòng chờ Admin phê duyệt.'
              : 'Đã cập nhật thông tin tiệm.',
        ),
      ),
    );
    await _reload();
  }

  String _statusLabel(String status) => switch (status) {
    'pending' => 'Chờ duyệt',
    'approved' => 'Đã duyệt',
    'rejected' => 'Bị từ chối',
    'banned' => 'Đã khóa',
    _ => status,
  };

  Widget _shopCard(Shop shop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    shop.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(_statusLabel(shop.status))),
              ],
            ),
            Text(shop.category == 'gas_station' ? 'Cây xăng' : 'Tiệm sửa xe'),
            Text('Địa chỉ: ${shop.address}'),
            Text('Hotline: ${shop.phone}'),
            Text(
              'Giờ: ${shop.openTime.substring(0, 5)} – ${shop.closeTime.substring(0, 5)}',
            ),
            Text('Đánh giá: ${shop.rating.toStringAsFixed(1)}/5'),
            if (shop.imageUrl != null && shop.imageUrl!.isNotEmpty)
              Text('Ảnh: ${shop.imageUrl}'),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: shop.status == 'banned'
                    ? null
                    : () => _openForm(shop),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Chỉnh sửa'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tiệm'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => AuthRepository().signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_business),
        label: const Text('Đăng ký tiệm'),
      ),
      body: FutureBuilder<List<Shop>>(
        future: _shops,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Không tải được danh sách: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(onPressed: _reload, child: const Text('Thử lại')),
                ],
              ),
            );
          }
          final shops = snapshot.data ?? <Shop>[];
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: shops.isEmpty
                  ? [
                      const SizedBox(height: 100),
                      const Center(
                        child: Text('Bạn chưa có tiệm. Hãy chọn Đăng ký tiệm.'),
                      ),
                    ]
                  : shops.map(_shopCard).toList(),
            ),
          );
        },
      ),
    );
  }
}
