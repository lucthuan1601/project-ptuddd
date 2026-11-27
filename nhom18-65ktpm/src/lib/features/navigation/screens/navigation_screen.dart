import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../map/widgets/app_map_view.dart';
import '../navigation_helper.dart';

/// Màn hình chỉ đường trực tiếp (UC-06) trên bản đồ OpenStreetMap dùng chung.
/// Tái sử dụng cho cả Rider (đến tiệm) và Owner / Volunteer (đến điểm sự cố).
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({
    super.key,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationTitle,
    this.destinationAddress,
    this.originTitle = 'Vị trí của bạn',
  });

  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final String destinationTitle;
  final String? destinationAddress;
  final String originTitle;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapController = MapController();
  bool _mapReady = false;

  late final LatLng _origin;
  late final LatLng _destination;
  late double _distanceMeters;
  late int _estimatedMinutes;
  late List<LatLng> _routePoints;
  bool _isRoadRoute = false;
  bool _isLoadingRoute = true;
  bool _routeFailed = false;

  @override
  void initState() {
    super.initState();
    _origin = LatLng(widget.originLat, widget.originLng);
    _destination = LatLng(widget.destinationLat, widget.destinationLng);
    _routePoints = [_origin, _destination];

    _distanceMeters = NavigationHelper.calculateDistanceMeters(
      startLat: widget.originLat,
      startLng: widget.originLng,
      endLat: widget.destinationLat,
      endLng: widget.destinationLng,
    );

    _estimatedMinutes =
        NavigationHelper.estimateMotorbikeMinutes(_distanceMeters);

    _loadRoadRoute();
  }

  Future<void> _loadRoadRoute() async {
    setState(() {
      _isLoadingRoute = true;
      _routeFailed = false;
    });

    final route = await NavigationHelper.fetchRoadRoute(
      originLat: widget.originLat,
      originLng: widget.originLng,
      destinationLat: widget.destinationLat,
      destinationLng: widget.destinationLng,
    );

    if (!mounted) return;
    if (route != null) {
      setState(() {
        _routePoints = route.points;
        _distanceMeters = route.distanceMeters;
        _estimatedMinutes = route.durationMinutes;
        _isRoadRoute = true;
        _isLoadingRoute = false;
        _routeFailed = false;
      });
      _fitBounds();
    } else {
      setState(() {
        _isLoadingRoute = false;
        _routeFailed = true;
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitBounds() {
    if (!_mapReady) return;

    final allPoints = [..._routePoints, _origin, _destination];
    final bounds = LatLngBounds.fromPoints(allPoints);

    // Tránh lỗi khi điểm nguồn trùng điểm đích.
    if ((bounds.north - bounds.south).abs() < 1e-5 &&
        (bounds.east - bounds.west).abs() < 1e-5) {
      _mapController.move(_destination, 16);
      return;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(48, 84, 48, 310),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      Marker(
        point: _origin,
        width: 28,
        height: 28,
        child: Tooltip(
          message: widget.originTitle,
          child: buildUserLocationMarker(),
        ),
      ),
      Marker(
        point: _destination,
        width: 170,
        height: 76,
        alignment: Alignment.bottomCenter,
        child: buildMapPin(
          color: const Color(0xFFD32F2F),
          icon: Icons.flag_rounded,
          selected: true,
          label: widget.destinationTitle,
        ),
      ),
    ];

    final polylines = <Polyline>[
      Polyline(
        points: _routePoints,
        color: _isRoadRoute ? const Color(0xFF1565C0) : const Color(0xFF1E88E5),
        borderColor: Colors.white,
        borderStrokeWidth: _isRoadRoute ? 2 : 0,
        strokeWidth: _isRoadRoute ? 6 : 4.5,
        pattern: _isRoadRoute
            ? const StrokePattern.solid()
            : StrokePattern.dashed(segments: const [12, 8]),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉ dẫn đường đi'),
        actions: [
          IconButton(
            tooltip: 'Căn giữa lộ trình',
            onPressed: _fitBounds,
            icon: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),
      body: Stack(
        children: [
          AppMapView(
            mapController: _mapController,
            initialCenter: _origin,
            initialZoom: 14,
            markers: markers,
            polylines: polylines,
            onMapReady: () {
              _mapReady = true;
              _fitBounds();
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              elevation: 8,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoadingRoute) const LinearProgressIndicator(minHeight: 3),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFFE3F2FD),
                              child: Icon(Icons.navigation, color: Color(0xFF1E88E5)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.destinationTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.destinationAddress != null)
                                    Text(
                                      widget.destinationAddress!,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            if (_isRoadRoute)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Đường bộ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1B5E20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (_routeFailed) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFFCC80)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    size: 16, color: Color(0xFFE65100)),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Không tải được tuyến đường chi tiết — hiển thị đường thẳng ước tính.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                  ),
                                  onPressed: _loadRoadRoute,
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetric(
                              icon: Icons.straighten,
                              label: _isRoadRoute ? 'Quãng đường' : 'Đường thẳng',
                              value: NavigationHelper.formatDistance(_distanceMeters),
                              color: Colors.blueAccent,
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.grey[300],
                            ),
                            _buildMetric(
                              icon: Icons.two_wheeler,
                              label: _isRoadRoute
                                  ? 'Thời gian dự kiến'
                                  : 'Xe máy ước tính',
                              value: NavigationHelper.formatDuration(_estimatedMinutes),
                              color: Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () =>
                                NavigationHelper.openExternalGoogleMaps(
                              destinationLat: widget.destinationLat,
                              destinationLng: widget.destinationLng,
                              context: context,
                            ),
                            icon: const Icon(Icons.directions),
                            label: const Text(
                              'Mở ứng dụng Google Maps ngoài',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
