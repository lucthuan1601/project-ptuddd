import 'package:flutter/material.dart';

import '../../../models/shop.dart';
import '../../../models/user.dart';
import '../../../models/volunteer_profile.dart';
import '../../../repositories/auth_repository.dart';
import '../data/admin_management_repository.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final _repository = AdminManagementRepository();
  final _search = TextEditingController();
  late Future<AdminManagementSnapshot> _future;
  String _query = '';
  String? _statusFilter;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _repository.load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
    if (!mounted) return;
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

  /// UC-14 A1/E2: yêu cầu nhập lý do từ chối từ 5–300 ký tự.
  Future<String?> _askRejectionReason(String title) async {
    final controller = TextEditingController();
    String? error;
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            maxLines: 3,
            maxLength: 300,
            decoration: InputDecoration(
              labelText: 'Lý do từ chối *',
              hintText: 'VD: Địa chỉ chưa rõ ràng / ảnh giấy tờ bị mờ',
              errorText: error,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.length < 5) {
                  setDialogState(
                    () => error = 'Vui lòng nhập lý do tối thiểu 5 ký tự',
                  );
                  return;
                }
                Navigator.pop(dialogContext, text);
              },
              child: const Text('Từ chối'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return reason;
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      _message('Đã cập nhật thành công.');
      await _reload();
    } on AppException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('Không thể cập nhật, vui lòng kiểm tra kết nối mạng.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _execute(
    String title,
    String question,
    Future<void> Function() action,
  ) async {
    if (_busy || !(await _confirm(title, question)) || !mounted) return;
    await _runAction(action);
  }

  Future<void> _reject(
    String title,
    Future<void> Function(String reason) action,
  ) async {
    if (_busy) return;
    final reason = await _askRejectionReason(title);
    if (reason == null || !mounted) return;
    await _runAction(() => action(reason));
  }

  Future<void> _viewIdCard(VolunteerProfile volunteer) async {
    if (_busy) return;
    try {
      final url = await _repository.idCardSignedUrl(volunteer);
      if (!mounted) return;
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
    } on AppException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('Không xem được giấy tờ, vui lòng thử lại.');
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

  bool _matchesQuery(Iterable<String> fields) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return fields.any((f) => f.toLowerCase().contains(q));
  }

  bool _matchesStatus(String status) =>
      _statusFilter == null || _statusFilter == status;

  Widget _filterBar() {
    const filters = [
      (label: 'Tất cả', value: null),
      (label: 'Chờ duyệt', value: 'pending'),
      (label: 'Đã duyệt', value: 'approved'),
      (label: 'Bị từ chối', value: 'rejected'),
      (label: 'Đã khóa', value: 'banned'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Tìm theo tên, email, SĐT...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(item.label),
                      selected: _statusFilter == item.value,
                      onSelected: (_) =>
                          setState(() => _statusFilter = item.value),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _busy || user.role == 'admin'
                    ? null
                    : () => _execute(
                        banned ? 'Mở khóa tài khoản?' : 'Khóa tài khoản?',
                        banned
                            ? 'Mở khóa tài khoản ${user.fullName} và khôi phục tiệm/hồ sơ liên quan.'
                            : 'Khóa tài khoản ${user.fullName} (đồng thời khóa tiệm/hồ sơ TNV và trả ca SOS đang xử lý về chờ nhận).',
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
            Text('Trạng thái: ${_stateLabel(status)}'),
            if (shop.rejectionReason?.trim().isNotEmpty ?? false)
              Text('Lý do từ chối: ${shop.rejectionReason}'),
            if (shop.imageUrl != null && shop.imageUrl!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    shop.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Text('Không tải được ảnh mặt tiền.'),
                  ),
                ),
              ),
            const SizedBox(height: 6),
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
                        : () => _reject(
                            'Từ chối tiệm "${shop.name}"',
                            (reason) => _repository.changeShopStatus(
                              shop,
                              'rejected',
                              rejectionReason: reason,
                            ),
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

  Widget _volunteerCard(
    VolunteerProfile volunteer,
    Map<String, UserModel> userById,
  ) {
    final status = volunteer.status;
    final user = userById[volunteer.userId];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.fullName ?? 'TNV (${volunteer.phone})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (user != null) Text(user.email),
            Text('SĐT: ${volunteer.phone}'),
            Text('Kỹ năng: ${volunteer.skills.join(', ')}'),
            if (volunteer.tools?.trim().isNotEmpty ?? false)
              Text('Dụng cụ: ${volunteer.tools}'),
            Text('Bán kính: ${volunteer.serviceRadiusKm} km'),
            Text('Trạng thái: ${_stateLabel(status)}'),
            if (volunteer.rejectionReason?.trim().isNotEmpty ?? false)
              Text('Lý do từ chối: ${volunteer.rejectionReason}'),
            const SizedBox(height: 6),
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
                            user?.fullName ?? volunteer.phone,
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
                        : () => _reject(
                            'Từ chối hồ sơ TNV',
                            (reason) => _repository.changeVolunteerStatus(
                              volunteer,
                              'rejected',
                              rejectionReason: reason,
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
                            user?.fullName ?? volunteer.phone,
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
    final tabBar = const TabBar(
      tabs: [
        Tab(text: 'Tiệm'),
        Tab(text: 'TNV'),
        Tab(text: 'Tài khoản'),
      ],
    );

    final body = Column(
      children: [
        if (widget.embedded) tabBar,
        _filterBar(),
        Expanded(
          child: FutureBuilder<AdminManagementSnapshot>(
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
              final userById = {for (final u in data.users) u.id: u};

              final shops = data.shops
                  .where(
                    (s) =>
                        _matchesStatus(s.status) &&
                        _matchesQuery([s.name, s.address, s.phone]),
                  )
                  .toList();
              final volunteers = data.volunteers
                  .where((v) {
                    final u = userById[v.userId];
                    return _matchesStatus(v.status) &&
                        _matchesQuery([
                          v.phone,
                          u?.fullName ?? '',
                          u?.email ?? '',
                        ]);
                  })
                  .toList();
              final users = data.users
                  .where((u) {
                    final statusOk = _statusFilter == null ||
                        (_statusFilter == 'banned'
                            ? u.status == 'banned'
                            : u.status == 'active');
                    return statusOk &&
                        _matchesQuery([u.fullName, u.email, u.phone, u.role]);
                  })
                  .toList();

              return TabBarView(
                children: [
                  _tabItems(shops, _shopCard),
                  _tabItems(volunteers, (v) => _volunteerCard(v, userById)),
                  _tabItems(users, _userCard),
                ],
              );
            },
          ),
        ),
      ],
    );

    return DefaultTabController(
      length: 3,
      child: widget.embedded
          ? body
          : Scaffold(
              appBar: AppBar(
                title: const Text('UC-14: Quản lý hệ thống'),
                actions: [
                  IconButton(
                    onPressed: _busy ? null : _reload,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
                bottom: tabBar,
              ),
              body: body,
            ),
    );
  }
}
