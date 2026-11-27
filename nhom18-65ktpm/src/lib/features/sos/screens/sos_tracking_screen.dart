import 'package:flutter/material.dart';

import '../../../models/sos_request.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/shop_repository.dart';
import '../../../repositories/sos_repository.dart';
import '../../review/widgets/review_form.dart';
import '../data/supabase_sos_repository.dart';
import '../sos_actions.dart';

/// UC-07 (bước 6): rider theo dõi ca SOS realtime cho tới khi có người nhận / hoàn thành.
class SosTrackingScreen extends StatefulWidget {
  const SosTrackingScreen({super.key, required this.sosId});

  final String sosId;

  @override
  State<SosTrackingScreen> createState() => _SosTrackingScreenState();
}

class _SosTrackingScreenState extends State<SosTrackingScreen> {
  final _repo = SupabaseSosRepository();
  late Stream<SosRequest?> _stream = _repo.watchById(widget.sosId);

  Future<SosContact>? _contact;
  bool _cancelling = false;

  void _retry() {
    setState(() => _stream = _repo.watchById(widget.sosId));
  }

  Future<void> _review(String shopId) async {
    String shopName = 'Tiệm đã hỗ trợ bạn';
    try {
      shopName = (await ShopRepository().byId(shopId))?.name ?? shopName;
    } catch (_) {
      // Không lấy được tên tiệm vẫn cho đánh giá.
    }
    if (!mounted) return;
    await showReviewSheet(context, shopId: shopId, shopName: shopName);
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy yêu cầu cứu hộ?'),
        content: const Text(
          'Các tiệm và tình nguyện viên sẽ không nhận được ca này nữa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hủy yêu cầu'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancelling = true);
    try {
      await _repo.cancel(widget.sosId);
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yêu cầu cứu hộ')),
      body: SafeArea(
        child: StreamBuilder<SosRequest?>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _Message(
                icon: Icons.wifi_off,
                text: 'Mất kết nối tới máy chủ, đang không cập nhật được trạng thái ca.',
                action: FilledButton(
                  onPressed: _retry,
                  child: const Text('Thử lại'),
                ),
              );
            }
            if (!snapshot.hasData &&
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final sos = snapshot.data;
            if (sos == null) {
              return const _Message(
                icon: Icons.search_off,
                text: 'Không tìm thấy yêu cầu cứu hộ.',
              );
            }

            switch (sos.status) {
              case 'pending':
                return _Waiting(cancelling: _cancelling, onCancel: _cancel);
              case 'accepted':
                _contact ??= _repo.contact(sos.id);
                return _Accepted(contact: _contact!);
              case 'completed':
                final shopId = sos.acceptedShopId;
                return _Message(
                  icon: Icons.check_circle,
                  text: 'Ca cứu hộ đã hoàn thành. Chúc bạn thượng lộ bình an!',
                  // UC-12 bước 8: ca do tiệm hỗ trợ thì gợi ý đánh giá (UC-08).
                  action: shopId == null
                      ? null
                      : FilledButton.icon(
                          onPressed: () => _review(shopId),
                          icon: const Icon(Icons.star),
                          label: const Text('Đánh giá dịch vụ'),
                        ),
                );
              default:
                return const _Message(
                  icon: Icons.cancel_outlined,
                  text: 'Bạn đã hủy yêu cầu cứu hộ này.',
                );
            }
          },
        ),
      ),
    );
  }
}

class _Waiting extends StatefulWidget {
  const _Waiting({required this.cancelling, required this.onCancel});

  final bool cancelling;
  final VoidCallback onCancel;

  @override
  State<_Waiting> createState() => _WaitingState();
}

class _WaitingState extends State<_Waiting>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) => Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60 + 100 * _pulse.value,
                      height: 60 + 100 * _pulse.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(
                          alpha: 0.35 * (1 - _pulse.value),
                        ),
                      ),
                    ),
                    child!,
                  ],
                ),
                child: Icon(Icons.sos, size: 56, color: color),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Đang chờ cứu hộ...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Đã gửi tín hiệu tới các tiệm và tình nguyện viên ở gần. '
              'Màn hình sẽ tự cập nhật khi có người tiếp nhận.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: widget.cancelling ? null : widget.onCancel,
              child: const Text('Hủy yêu cầu'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Accepted extends StatelessWidget {
  const _Accepted({required this.contact});

  final Future<SosContact> contact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<SosContact>(
          future: contact,
          builder: (context, snapshot) {
            final info = snapshot.data;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.handshake,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Đã có người tiếp nhận!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Người hỗ trợ đang di chuyển tới vị trí của bạn.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const CircularProgressIndicator()
                else if (info == null)
                  Text(
                    snapshot.error?.toString() ??
                        'Không tải được thông tin người hỗ trợ.',
                    textAlign: TextAlign.center,
                  )
                else
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(info.name),
                      subtitle: Text(info.phone),
                      trailing: IconButton.filled(
                        tooltip: 'Gọi ngay',
                        onPressed: () => launchPhoneCall(context, info.phone),
                        icon: const Icon(Icons.call),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
