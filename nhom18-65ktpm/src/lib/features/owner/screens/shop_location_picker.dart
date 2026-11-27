import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../repositories/auth_repository.dart';
import '../data/shop_location_rules.dart';

class ShopPickedLocation {
  const ShopPickedLocation({required this.position, required this.address});

  final LatLng position;
  final String address;
}

class ShopLocationPicker extends StatefulWidget {
  const ShopLocationPicker({
    super.key,
    this.initialPosition,
    this.initialAddress,
  });

  final LatLng? initialPosition;
  final String? initialAddress;

  @override
  State<ShopLocationPicker> createState() => _ShopLocationPickerState();
}

class _ShopLocationPickerState extends State<ShopLocationPicker> {
  static const _defaultCenter = LatLng(21.0285, 105.8542);

  final geocoding.Geocoding _geocoder = geocoding.Geocoding(
    locale: const Locale('vi', 'VN'),
  );
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _address = TextEditingController();
  final _search = TextEditingController();
  GoogleMapController? _controller;
  LatLng? _selected;
  bool _busyGps = false;
  bool _busySearch = false;
  bool _busyAddress = false;
  int _manualVersion = 0;
  int _addressVersion = 0;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialPosition;
    _address.text = widget.initialAddress ?? '';
    if (_selected != null) {
      _fillCoordinates(_selected!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_useGps());
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _address.dispose();
    _search.dispose();
    super.dispose();
  }

  void _fillCoordinates(LatLng position) {
    _latitude.text = position.latitude.toStringAsFixed(6);
    _longitude.text = position.longitude.toStringAsFixed(6);
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatAddress(geocoding.Placemark p) {
    return [
          p.street,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.country,
        ]
        .whereType<String>()
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toSet()
        .join(', ');
  }

  Future<void> _reverseGeocode(LatLng point) async {
    final version = ++_addressVersion;
    setState(() => _busyAddress = true);
    try {
      final places = await _geocoder.placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (!mounted || version != _addressVersion || places.isEmpty) return;
      final address = _formatAddress(places.first);
      if (address.isNotEmpty) _address.text = address;
    } catch (_) {
      if (mounted && version == _addressVersion) {
        _message('Chưa lấy được địa chỉ. Bạn có thể nhập địa chỉ thủ công.');
      }
    } finally {
      if (mounted && version == _addressVersion) {
        setState(() => _busyAddress = false);
      }
    }
  }

  void _select(LatLng point, {bool manual = true}) {
    final error = ShopLocationRules.validateCoordinates(
      point.latitude,
      point.longitude,
    );
    if (error != null) {
      _message(error);
      return;
    }
    if (manual) _manualVersion++;
    setState(() {
      _selected = point;
      _fillCoordinates(point);
    });
    unawaited(_reverseGeocode(point));
  }

  Future<void> _moveTo(LatLng point, {bool manual = true}) async {
    if (ShopLocationRules.validateCoordinates(
          point.latitude,
          point.longitude,
        ) !=
        null) {
      _message('Vị trí không nằm trong phạm vi phục vụ.');
      return;
    }
    _select(point, manual: manual);
    await _controller?.animateCamera(CameraUpdate.newLatLngZoom(point, 16));
  }

  Future<void> _useGps() async {
    if (_busyGps) return;
    final version = _manualVersion;
    setState(() => _busyGps = true);
    try {
      if (!kIsWeb) {
        if (!await Geolocator.isLocationServiceEnabled()) {
          throw const AppException('GPS đang tắt. Hãy bật dịch vụ vị trí.');
        }
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw const AppException(
            'Bạn chưa cấp quyền vị trí. Hãy tìm địa chỉ hoặc đặt ghim thủ công.',
          );
        }
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted || _manualVersion != version) return;
      await _moveTo(LatLng(p.latitude, p.longitude), manual: false);
    } on AppException catch (e) {
      _message(e.message);
    } catch (_) {
      _message(
        'Không lấy được GPS. Hãy nhập địa chỉ hoặc chọn vị trí trên bản đồ.',
      );
    } finally {
      if (mounted) setState(() => _busyGps = false);
    }
  }

  Future<void> _findAddress() async {
    final text = _search.text.trim();
    if (text.isEmpty || _busySearch) return;
    setState(() => _busySearch = true);
    try {
      final matches = await _geocoder.locationFromAddress(text);
      if (matches.isEmpty) {
        throw const AppException('Không tìm thấy địa chỉ này.');
      }
      final first = matches.first;
      final point = LatLng(first.latitude, first.longitude);
      if (ShopLocationRules.validateCoordinates(
            point.latitude,
            point.longitude,
          ) !=
          null) {
        throw const AppException('Vị trí không nằm trong phạm vi phục vụ.');
      }
      await _moveTo(point);
    } on AppException catch (e) {
      _message(e.message);
    } catch (_) {
      _message(
        'Không tìm được địa chỉ. Hãy đặt ghim hoặc nhập tọa độ thủ công.',
      );
    } finally {
      if (mounted) setState(() => _busySearch = false);
    }
  }

  Future<void> _applyCoordinates() async {
    final latitude = double.tryParse(_latitude.text.trim());
    final longitude = double.tryParse(_longitude.text.trim());
    final error = ShopLocationRules.validateCoordinates(latitude, longitude);
    if (error != null) {
      _message(error);
      return;
    }
    await _moveTo(LatLng(latitude!, longitude!));
  }

  void _confirm() {
    final latitude = double.tryParse(_latitude.text.trim());
    final longitude = double.tryParse(_longitude.text.trim());
    final error = ShopLocationRules.validateCoordinates(latitude, longitude);
    if (error != null) {
      _message(error);
      return;
    }
    if (_address.text.trim().isEmpty) {
      _message('Vui lòng nhập địa chỉ tiệm trước khi xác nhận.');
      return;
    }
    Navigator.of(context).pop(
      ShopPickedLocation(
        position: LatLng(latitude!, longitude!),
        address: _address.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      appBar: AppBar(title: const Text('Ghim vị trí tiệm')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialPosition ?? _defaultCenter,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _controller = controller;
                if (_selected != null) {
                  unawaited(
                    controller.animateCamera(
                      CameraUpdate.newLatLngZoom(_selected!, 16),
                    ),
                  );
                }
              },
              onTap: _select,
              markers: selected == null
                  ? <Marker>{}
                  : <Marker>{
                      Marker(
                        markerId: const MarkerId('shop'),
                        position: selected,
                        draggable: true,
                        onDragEnd: _select,
                        infoWindow: const InfoWindow(title: 'Vị trí tiệm'),
                      ),
                    },
              zoomControlsEnabled: true,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _search,
                        decoration: const InputDecoration(
                          labelText: 'Tìm đường hoặc thành phố',
                        ),
                        onSubmitted: (_) => _findAddress(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Tìm địa chỉ',
                      onPressed: _busySearch ? null : _findAddress,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latitude,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(labelText: 'Vĩ độ'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _longitude,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(labelText: 'Kinh độ'),
                      ),
                    ),
                  ],
                ),
                if (_busyAddress) const LinearProgressIndicator(),
                TextField(
                  controller: _address,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ xem trước (có thể sửa)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _applyCoordinates,
                      icon: const Icon(Icons.place),
                      label: const Text('Đặt ghim'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busyGps ? null : _useGps,
                      icon: const Icon(Icons.my_location),
                      label: Text(
                        _busyGps ? 'Đang lấy GPS...' : 'Vị trí hiện tại',
                      ),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: _confirm,
                  icon: const Icon(Icons.check),
                  label: const Text('Xác nhận vị trí này'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
