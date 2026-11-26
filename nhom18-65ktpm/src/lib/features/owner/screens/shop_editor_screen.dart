import 'package:flutter/material.dart';

import '../../../models/shop.dart';
import '../data/owner_shop_repository.dart';

/// UC-09: tạo và sửa thông tin tiệm.
/// Bước UC-10 sẽ thay nhập tọa độ thủ công bằng bản đồ tương tác.
class ShopEditorScreen extends StatefulWidget {
  const ShopEditorScreen({super.key, this.shop});

  final Shop? shop;

  @override
  State<ShopEditorScreen> createState() => _ShopEditorScreenState();
}

class _ShopEditorScreenState extends State<ShopEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = OwnerShopRepository();

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _imageUrl;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;
  late String _category;
  late TimeOfDay _openTime;
  late TimeOfDay _closeTime;
  bool _saving = false;

  TimeOfDay _readTime(String? text, TimeOfDay fallback) {
    final parts = text?.split(':') ?? [];
    if (parts.length < 2) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return fallback;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void initState() {
    super.initState();
    final shop = widget.shop;
    _name = TextEditingController(text: shop?.name ?? '');
    _phone = TextEditingController(text: shop?.phone ?? '');
    _address = TextEditingController(text: shop?.address ?? '');
    _imageUrl = TextEditingController(text: shop?.imageUrl ?? '');
    _latitude = TextEditingController(
      text: shop == null ? '' : shop.latitude.toStringAsFixed(6),
    );
    _longitude = TextEditingController(
      text: shop == null ? '' : shop.longitude.toStringAsFixed(6),
    );
    _category = shop?.category ?? 'repair_shop';
    _openTime = _readTime(shop?.openTime, const TimeOfDay(hour: 7, minute: 0));
    _closeTime = _readTime(
      shop?.closeTime,
      const TimeOfDay(hour: 21, minute: 0),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _imageUrl.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  String _sqlTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  Future<void> _selectTime({required bool opening}) async {
    final chosen = await showTimePicker(
      context: context,
      initialTime: opening ? _openTime : _closeTime,
    );
    if (!mounted || chosen == null) return;
    setState(() {
      if (opening) {
        _openTime = chosen;
      } else {
        _closeTime = chosen;
      }
    });
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    if (_openTime.hour == _closeTime.hour &&
        _openTime.minute == _closeTime.minute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giờ mở và giờ đóng phải khác nhau.')),
      );
      return;
    }

    final draft = ShopDraft(
      name: _name.text,
      category: _category,
      phone: _phone.text,
      address: _address.text,
      latitude: double.parse(_latitude.text.trim()),
      longitude: double.parse(_longitude.text.trim()),
      openTime: _sqlTime(_openTime),
      closeTime: _sqlTime(_closeTime),
      imageUrl: _imageUrl.text,
    );

    setState(() => _saving = true);
    try {
      if (widget.shop == null) {
        await _repository.create(draft);
      } else {
        await _repository.update(shop: widget.shop!, draft: draft);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không lưu được tiệm: $error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.shop != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Chỉnh sửa tiệm' : 'Đăng ký tiệm')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!editing)
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Text('Tiệm mới sẽ ở trạng thái chờ Admin phê duyệt.'),
              ),
            TextFormField(
              controller: _name,
              maxLength: 150,
              decoration: const InputDecoration(labelText: 'Tên tiệm *'),
              validator: (value) {
                final n = value?.trim().length ?? 0;
                if (n < 3 || n > 150) {
                  return 'Tên tiệm phải từ 3 đến 150 ký tự.';
                }

                return null;
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Loại cơ sở *'),
              items: const [
                DropdownMenuItem(
                  value: 'repair_shop',
                  child: Text('Tiệm sửa xe'),
                ),
                DropdownMenuItem(value: 'gas_station', child: Text('Cây xăng')),
              ],
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(labelText: 'Hotline *'),
              validator: (value) =>
                  RegExp(r'^0[0-9]{9}$').hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Hotline phải có 10 chữ số và bắt đầu bằng 0.',
            ),
            TextFormField(
              controller: _address,
              minLines: 1,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Địa chỉ *'),
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'Vui lòng nhập địa chỉ tiệm.'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () => _selectTime(opening: true),
                    icon: const Icon(Icons.schedule),
                    label: Text('Mở: ${_openTime.format(context)}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () => _selectTime(opening: false),
                    icon: const Icon(Icons.schedule),
                    label: Text('Đóng: ${_closeTime.format(context)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Tọa độ tiệm (tạm nhập tay; UC-10 sẽ có bản đồ)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitude,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Vĩ độ *'),
                    validator: (value) {
                      final number = double.tryParse(value?.trim() ?? '');
                      return number != null &&
                              number.isFinite &&
                              number >= -90 &&
                              number <= 90
                          ? null
                          : 'Vĩ độ -90 đến 90';
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _longitude,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Kinh độ *'),
                    validator: (value) {
                      final number = double.tryParse(value?.trim() ?? '');
                      return number != null &&
                              number.isFinite &&
                              number >= -180 &&
                              number <= 180
                          ? null
                          : 'Kinh độ -180 đến 180';
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageUrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'URL ảnh (tùy chọn)',
                helperText:
                    'Tải ảnh JPG/PNG sẽ bổ sung khi nhóm duyệt dependency.',
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return null;
                final uri = Uri.tryParse(text);
                return uri != null &&
                        uri.hasAuthority &&
                        (uri.scheme == 'https' || uri.scheme == 'http')
                    ? null
                    : 'Nhập đường dẫn http(s) hợp lệ.';
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_saving ? 'Đang lưu...' : 'Lưu thông tin tiệm'),
            ),
          ],
        ),
      ),
    );
  }
}
