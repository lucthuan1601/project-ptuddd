import 'package:flutter/material.dart';

import '../../../models/shop.dart';
import '../../../models/user.dart';
import '../../../models/volunteer_profile.dart';
import '../data/admin_management_repository.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final _repository = AdminManagementRepository();
  late Future<AdminManagementSnapshot> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _repository.load();
  }

  Future<void> _reload() async {
    final next = _repository.load();
    setState(() => _future = next);
    try {
      await next;
    } catch (_) {
      _message('Không thể tải lại danh sách.');
    }
  }

  void _message(String text) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<bool> _confirm(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _execute(
    String title,
    String question,
    Future<void> Function() action,
  ) async {
    if (_busy || !(await _confirm(title, question)) || !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) {
        return;
      }
      _message('Đã cập nhật thành công.');
      await _reload();
    } catch (error) {
      _message('Không thể cập nhật: $error');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _viewIdCard(VolunteerProfile volunteer) async {
    if (_busy) {
      return;
    }
    try {
      final url = await _repository.idCardSignedUrl(volunteer);
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Giấy tờ xác minh'),
          content: SizedBox(
            width: 420,
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Text('Không hiển thị được giấy tờ.'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (error) {
      _message('Không xem được giấy tờ: $error');
    }
  }

  String _stateLabel(String value) => switch (value) {
    'pending' => 'Chờ duyệt',
    'approved' => 'Đã duyệt',
    'rejected' => 'Bị từ chối',
    'banned' => 'Đã khóa',
    'active' => 'Hoạt động',
    _ => value,
  };

  Widget _actions(Widget child) => Align(
    alignment: Alignment.centerRight,
    child: Wrap(spacing: 8, runSpacing: 6, children: [child]),
  );

  Widget _userCard(UserModel user) {
    final banned = user.status == 'banned';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.fullName, style: Theme.of(context).textTheme.titleMedium),
            Text(user.email),
            Text('SĐT: ${user.phone}'),
            Text('Vai trò: ${user.role}'),
            Text('Trạng thái: ${_stateLabel(user.status)}'),
            _actions(
              OutlinedButton.icon(
                onPressed: _busy || user.role == 'admin'
                    ? null
                    : () => _execute(
                        banned ? 'Mở khóa tài khoản?' : 'Khóa tài khoản?',
                        user.fullName,
                        () => _repository.changeUserStatus(
                          user,
                          banned ? 'active' : 'banned',
                        ),
                      ),
                icon: Icon(banned ? Icons.lock_open : Icons.lock_outline),
                label: Text(
                  user.role == 'admin'
                      ? 'Tài khoản Admin'
                      : banned
                      ? 'Mở khóa'
                      : 'Khóa',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shopCard(Shop shop) {
    final status = shop.status;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shop.name, style: Theme.of(context).textTheme.titleMedium),
            Text(shop.category == 'gas_station' ? 'Cây xăng' : 'Tiệm sửa xe'),
            Text('Địa chỉ: ${shop.address}'),
            Text('SĐT: ${shop.phone}'),
            Text('Tọa độ: ${shop.latitude}, ${shop.longitude}'),
            Text('Trạng thái: ${_stateLabel(status)}'),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (status != 'approved')
                  FilledButton.tonal(
                    onPressed: _busy
                        ? null
                        : () => _execute(
                            'Duyệt tiệm?',
                            shop.name,
                            () =>
                                _repository.changeShopStatus(shop, 'approved'),
                          ),
                    child: const Text('Phê duyệt'),
                  ),
                if (status == 'pending')
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _execute(
                            'Từ chối tiệm?',
                            'Hệ thống hiện chưa có trường lưu lý do từ chối. Chỉ trạng thái rejected được lưu. Tiếp tục?',
                            () =>
                                _repository.changeShopStatus(shop, 'rejected'),
                          ),
                    child: const Text('Từ chối'),
                  ),
                if (status == 'approved' || status == 'rejected')
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _execute(
                            'Khóa tiệm?',
                            shop.name,
                            () => _repository.changeShopStatus(shop, 'banned'),
                          ),
                    child: const Text('Khóa tiệm'),
                  ),
                if (status == 'banned')
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _execute(
                            'Khôi phục hồ sơ?',
                            'Hồ sơ sẽ quay về trạng thái chờ duyệt.',
                            () => _repository.changeShopStatus(shop, 'pending'),
                          ),
                    child: const Text('Khôi phục'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _volunteerCard(VolunteerProfile volunteer) {
    final status = volunteer.status;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hồ sơ TNV: ${volunteer.id}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('SĐT: ${volunteer.phone}'),
            Text('Kỹ năng: ${volunteer.skills.join(', ')}'),
            Text('Bán kính: ${volunteer.serviceRadiusKm} km'),
            Text('Trạng thái: ${_stateLabel(status)}'),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                OutlinedButton(
                  onPressed: _busy ? null : () => _viewIdCard(volunteer),
                  child: const Text('Xem giấy tờ'),
                ),
                if (status != 'approved')
                  FilledButton.tonal(
                    onPressed: _busy
                        ? null
                        : () => _execute(
                            'Duyệt tình nguyện viên?',
                            volunteer.phone,
                            () => _repository.changeVolunteerStatus(
                              volunteer,
                              'approved',
                            ),
                          ),
                    child: const Text('Phê duyệt'),
                  ),
                if (status == 'pending')
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _execute(
                            'Từ chối hồ sơ?',
                            'Schema chưa có trường lưu lý do từ chối. Chỉ trạng thái rejected được lưu. Tiếp tục?',
                            () => _repository.changeVolunteerStatus(
                              volunteer,
                              'rejected',
                            ),
                          ),
                    child: const Text('Từ chối'),
                  ),
                if (status == 'approved' || status == 'rejected')
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _execute(
                            'Khóa tình nguyện viên?',
                            volunteer.phone,
                            () => _repository.changeVolunteerStatus(
                              volunteer,
                              'banned',
                            ),
                          ),
                    child: const Text('Khóa'),
                  ),
                if (status == 'banned')
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _execute(
                            'Khôi phục hồ sơ?',
                            'Hồ sơ quay về chờ duyệt.',
                            () => _repository.changeVolunteerStatus(
                              volunteer,
                              'pending',
                            ),
                          ),
                    child: const Text('Khôi phục'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItems<T>(List<T> items, Widget Function(T) builder) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        children: items.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Không có dữ liệu.')),
                ),
              ]
            : items.map(builder).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('UC-14: Quản lý hệ thống'),
          actions: [
            IconButton(
              onPressed: _busy ? null : _reload,
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tài khoản'),
              Tab(text: 'Tiệm'),
              Tab(text: 'TNV'),
            ],
          ),
        ),
        body: FutureBuilder<AdminManagementSnapshot>(
          future: _future,
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
                        'Không tải được dữ liệu: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }
            final data = snapshot.data!;
            return TabBarView(
              children: [
                _tabItems(data.users, _userCard),
                _tabItems(data.shops, _shopCard),
                _tabItems(data.volunteers, _volunteerCard),
              ],
            );
          },
        ),
      ),
    );
  }
}
