import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShopLocationPicker extends StatefulWidget {
  const ShopLocationPicker({super.key, this.initialPosition});

  final LatLng? initialPosition;

  @override
  State<ShopLocationPicker> createState() => _ShopLocationPickerState();
}

class _ShopLocationPickerState extends State<ShopLocationPicker> {
  static const _defaultCenter = LatLng(21.0285, 105.8542);

  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  GoogleMapController? _mapController;
  LatLng? _selected;
  bool _loadingGps = false;
  int _manualSelectionVersion = 0;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialPosition;
    if (_selected != null) {
      _fillCoordinates(_selected!);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _fillCoordinates(LatLng position) {
    _latitudeController.text = position.latitude.toStringAsFixed(6);
    _longitudeController.text = position.longitude.toStringAsFixed(6);
  }

  void _select(LatLng position, {bool manual = true}) {
    if (manual) {
      _manualSelectionVersion++;
    }
    setState(() {
      _selected = position;
      _fillCoordinates(position);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _useGps() async {
    if (_loadingGps) {
      return;
    }
    final versionBeforeRequest = _manualSelectionVersion;
    setState(() => _loadingGps = true);

    try {
      if (!kIsWeb) {
        if (!await Geolocator.isLocationServiceEnabled()) {
          throw Exception('Dich vu vi tri dang tat. Hay bat GPS.');
        }

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied) {
          throw Exception('Ban chua cap quyen vi tri.');
        }
        if (permission == LocationPermission.deniedForever) {
          throw Exception('Quyen vi tri da bi chan trong cai dat.');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (!mounted || _manualSelectionVersion != versionBeforeRequest) {
        return;
      }
      final point = LatLng(position.latitude, position.longitude);
      _select(point, manual: false);
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(point, 16),
      );
    } catch (error) {
      if (mounted) {
        _showError(
          'Khong lay duoc GPS: $error. Co the cham ban do de chon tay.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingGps = false);
      }
    }
  }

  LatLng? _readCoordinates() {
    final lat = double.tryParse(_latitudeController.text.trim());
    final lng = double.tryParse(_longitudeController.text.trim());
    if (lat == null ||
        lng == null ||
        !lat.isFinite ||
        !lng.isFinite ||
        lat < -90 ||
        lat > 90 ||
        lng < -180 ||
        lng > 180) {
      return null;
    }
    return LatLng(lat, lng);
  }

  Future<void> _applyCoordinates() async {
    final point = _readCoordinates();
    if (point == null) {
      _showError('Vi do phai tu -90 den 90, kinh do tu -180 den 180.');
      return;
    }
    _select(point);
    await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(point, 16));
  }

  void _confirm() {
    final point = _readCoordinates();
    if (point == null) {
      _showError('Hay chon hoac nhap vi tri hop le.');
      return;
    }
    Navigator.of(context).pop(point);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      appBar: AppBar(title: const Text('Ghim vi tri tiem - UC-10')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialPosition ?? _defaultCenter,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                if (_selected != null) {
                  controller.animateCamera(
                    CameraUpdate.newLatLngZoom(_selected!, 16),
                  );
                }
              },
              onTap: _select,
              markers: selected == null
                  ? <Marker>{}
                  : <Marker>{
                      Marker(
                        markerId: const MarkerId('my_shop'),
                        position: selected,
                        draggable: true,
                        onDragEnd: _select,
                        infoWindow: const InfoWindow(title: 'Vi tri tiem'),
                      ),
                    },
              zoomControlsEnabled: true,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  selected == null
                      ? 'Cham len ban do, keo ghim hoac nhap toa do.'
                      : 'Ghim: ${selected.latitude.toStringAsFixed(6)}, '
                            '${selected.longitude.toStringAsFixed(6)}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Vi do',
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _longitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Kinh do',
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _applyCoordinates,
                  icon: const Icon(Icons.place),
                  label: const Text('Dat ghim theo toa do'),
                ),
                OutlinedButton.icon(
                  onPressed: _loadingGps ? null : _useGps,
                  icon: _loadingGps
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    _loadingGps ? 'Dang lay GPS...' : 'Dung vi tri hien tai',
                  ),
                ),
                FilledButton.icon(
                  onPressed: _confirm,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Xac nhan vi tri'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
