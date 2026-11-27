import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/owner/data/owner_shop_repository.dart';
import '../../features/owner/screens/shop_editor_screen.dart';
import '../../features/owner/widgets/shop_open_status_card.dart';
import '../../features/sos/widgets/sos_inbox.dart';
import '../../models/shop.dart';
import '../../repositories/auth_repository.dart';
import '../push_service.dart';

/// Phân hệ Chủ tiệm: UC-09, UC-10, UC-11 (quản lý tiệm) & UC-12 (hộp thư SOS).
class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});

  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  final _repository = OwnerShopRepository();
  late Future<List<Shop>> _shops;
  StreamSubscription<String>? _pushSubscription;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _shops = _repository.myShops();
    if (PushService.takeInitialSosId() != null) _tab = 1;
    _pushSubscription = PushService.sosAlerts.listen((_) {
      if (mounted) setState(() => _tab = 1);
    });
  }

  @override
  void dispose() {
    _pushSubscription?.cancel();
    super.dispose();
  }

  Future<void> _reload() async {
    final future = _repository.myShops();
    setState(() => _shops = future);
    try {
      await future;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tải lại được danh sách tiệm.')),
        );
      }
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

  String _clock(String value) =>
      value.length >= 5 ? value.substring(0, 5) : value;

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
            Text('Giờ: ${_clock(shop.openTime)} – ${_clock(shop.closeTime)}'),
            Text('Đánh giá: ${shop.rating.toStringAsFixed(1)}/5'),
            if (shop.imageUrl != null && shop.imageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.network(
                  shop.imageUrl!,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Text('Không hiển thị được ảnh tiệm.'),
                ),
              ),
            if (shop.status == 'rejected' &&
                (shop.rejectionReason?.trim().isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Lý do từ chối: ${shop.rejectionReason}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (shop.status == 'approved')
              ShopOpenStatusCard(shop: shop, compact: true, onChanged: _reload),
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

  Widget _buildShopsTab() {
    return FutureBuilder<List<Shop>>(
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
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Không tải được danh sách. Kiểm tra mạng và quyền truy cập.',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tab == 0 ? 'Quản lý tiệm' : 'Yêu cầu cứu hộ SOS'),
        actions: [
          if (_tab == 0)
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
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add_business),
              label: const Text('Đăng ký tiệm'),
            )
          : null,
      body: _tab == 0
          ? _buildShopsTab()
          : SosInbox(onCaseFinished: _reload),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront),
            label: 'Tiệm của tôi',
          ),
          NavigationDestination(
            icon: Icon(Icons.sos),
            label: 'Cứu hộ SOS',
          ),
        ],
      ),
    );
  }
}
