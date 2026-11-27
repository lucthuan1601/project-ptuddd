import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';
import '../../features/call/call_helper.dart';
import '../../features/map/location_service.dart';
import '../../features/navigation/screens/navigation_screen.dart';
import '../../features/shop/screens/shop_detail_screen.dart';
import '../../features/shop/shop_filter.dart';
import '../../features/shop/widgets/shop_carousel.dart';
import '../../features/shop/widgets/shop_filter_bar.dart';
import '../../features/sos/screens/sos_request_screen.dart';
import '../../models/shop.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/shop_repository.dart';

/// Màn hình chính phân hệ Khách hàng (Rider), tích hợp UC-02 → UC-08.
class RiderShell extends StatefulWidget {
  const RiderShell({super.key});

  @override
  State<RiderShell> createState() => _RiderShellState();
}

class _RiderShellState extends State<RiderShell> {
  GoogleMapController? _mapController;

  LatLng _currentLocation = LocationService.defaultHanoi;
  String _currentAddress = 'Đang xác định vị trí...';
  bool _isLoadingLocation = true;
  bool _isLoadingShops = false;

  // Dữ liệu tiệm
  List<Shop> _shops = [];
  String? _selectedShopId;

  // Trạng thái bộ lọc (UC-03)
  String _searchQuery = '';
  String? _selectedCategory; // null = Tất cả, 'repair_shop', 'gas_station'
  int _selectedRadius = 3000; // 3km mặc định
  bool _isOpenOnly = false;

  RealtimeChannel? _shopsSubscription;

  @override
  void initState() {
    super.initState();
    _initLocationAndShops();
    _subscribeToShopsRealtime();
  }

  @override
  void dispose() {
    final channel = _shopsSubscription;
    if (channel != null) {
      unawaited(supabase.removeChannel(channel));
    }
    _mapController?.dispose();
    super.dispose();
  }

  /// Lắng nghe thay đổi trạng thái đóng/mở cửa của tiệm theo thời gian thực (Supabase Realtime).
  void _subscribeToShopsRealtime() {
    _shopsSubscription = supabase
        .channel('public:shops-${DateTime.now().microsecondsSinceEpoch}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'shops',
          callback: (_) {
            _fetchNearbyShops(showLoading: false);
          },
        )
        .subscribe();
  }

  /// UC-02: Định vị GPS hiện tại và tải danh sách tiệm ban đầu.
  Future<void> _initLocationAndShops() async {
    setState(() => _isLoadingLocation = true);

    final res = await LocationService.getCurrentLocation();

    if (!mounted) return;
    setState(() {
      _isLoadingLocation = false;
      if (res.position != null) {
        _currentLocation = res.position!;
      }
      _currentAddress = res.address ??
          (res.position != null
              ? 'Tọa độ: ${res.position!.latitude.toStringAsFixed(4)}, ${res.position!.longitude.toStringAsFixed(4)}'
              : 'Hà Nội');
    });

    if (res.isGpsDisabled) {
      _showGpsDisabledDialog();
    } else if (res.isPermissionDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Ứng dụng không có quyền GPS. Đang hiển thị vị trí mặc định tại Hà Nội.',
          ),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Cài đặt',
            textColor: Colors.white,
            onPressed: () => unawaited(Geolocator.openAppSettings()),
          ),
        ),
      );
    } else if (res.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.errorMessage!),
          backgroundColor: Colors.orange,
        ),
      );
    }

    _animateCameraTo(_currentLocation);
    await _fetchNearbyShops();
  }

  void _showGpsDisabledDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dịch vụ vị trí bị tắt'),
        content: const Text(
          'Vui lòng bật định vị GPS trên thiết bị để ứng dụng có thể tìm tiệm sửa xe và cây xăng gần bạn nhất.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Bỏ qua'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              unawaited(Geolocator.openLocationSettings());
            },
            child: const Text('Mở cài đặt'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _initLocationAndShops();
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _animateCameraTo(LatLng target, {double zoom = 14.5}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  /// UC-03: Tải danh sách tiệm trong bán kính qua RPC PostGIS.
  Future<void> _fetchNearbyShops({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoadingShops = true);
    }

    try {
      final list = await ShopRepository().nearby(
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        radiusMeters: _selectedRadius,
        category: _selectedCategory,
        openOnly: _isOpenOnly,
      );

      if (mounted) {
        setState(() {
          _shops = list;
          _isLoadingShops = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingShops = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lỗi kết nối cơ sở dữ liệu khi tải danh sách tiệm.'),
            backgroundColor: Colors.redAccent,
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () => _fetchNearbyShops(),
            ),
          ),
        );
      }
    }
  }

  List<Shop> get _filteredShops => filterShops(_shops, _searchQuery);

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Marker vị trí người dùng (chấm xanh)
    markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: _currentLocation,
        infoWindow: const InfoWindow(title: 'Vị trí của bạn'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // Markers cho các tiệm
    for (final shop in _filteredShops) {
      final isRepair = shop.category == 'repair_shop';
      final isSelected = shop.id == _selectedShopId;

      markers.add(
        Marker(
          markerId: MarkerId(shop.id),
          position: LatLng(shop.latitude, shop.longitude),
          infoWindow: InfoWindow(
            title: shop.name,
            snippet: shop.isOpen ? 'Đang mở cửa' : 'Tạm đóng cửa',
            onTap: () => _openShopDetail(shop),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected
                ? BitmapDescriptor.hueViolet
                : (isRepair
                    ? BitmapDescriptor.hueOrange
                    : BitmapDescriptor.hueBlue),
          ),
          onTap: () {
            setState(() => _selectedShopId = shop.id);
            _animateCameraTo(LatLng(shop.latitude, shop.longitude), zoom: 15.5);
          },
        ),
      );
    }

    return markers;
  }

  void _openShopDetail(Shop shop) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShopDetailScreen(
          shop: shop,
          userLat: _currentLocation.latitude,
          userLng: _currentLocation.longitude,
        ),
      ),
    );
  }

  void _onNavigateToShop(Shop shop) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NavigationScreen(
          originLat: _currentLocation.latitude,
          originLng: _currentLocation.longitude,
          destinationLat: shop.latitude,
          destinationLng: shop.longitude,
          destinationTitle: shop.name,
          destinationAddress: shop.address,
        ),
      ),
    );
  }

  /// UC-07: mở màn hình gửi/theo dõi tín hiệu SOS thực tế.
  void _openSosScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SosRequestScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map nền
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 14.5,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _buildMarkers(),
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (_) => setState(() => _selectedShopId = null),
          ),

          // 2. Thanh Top Bar địa chỉ & Đăng xuất
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location, color: Color(0xFF1E88E5), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vị trí hiện tại của bạn',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              Text(
                                _currentAddress,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Làm mới vị trí',
                          onPressed: _initLocationAndShops,
                          icon: _isLoadingLocation
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh, size: 20),
                        ),
                        IconButton(
                          tooltip: 'Đăng xuất',
                          onPressed: () => AuthRepository().signOut(),
                          icon: const Icon(Icons.logout, size: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bộ lọc tìm kiếm & bán kính (UC-03)
                  ShopFilterBar(
                    searchQuery: _searchQuery,
                    selectedCategory: _selectedCategory,
                    selectedRadiusMeters: _selectedRadius,
                    isOpenOnly: _isOpenOnly,
                    onSearchChanged: (q) => setState(() => _searchQuery = q),
                    onCategoryChanged: (cat) {
                      setState(() => _selectedCategory = cat);
                      _fetchNearbyShops();
                    },
                    onRadiusChanged: (rad) {
                      setState(() => _selectedRadius = rad);
                      _fetchNearbyShops();
                    },
                    onOpenOnlyChanged: (openOnly) {
                      setState(() => _isOpenOnly = openOnly);
                      _fetchNearbyShops();
                    },
                  ),
                ],
              ),
            ),
          ),

          // 3. Thanh hiển thị trạng thái đang tải
          if (_isLoadingShops)
            Positioned(
              top: 180,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Đang tìm kiếm...', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

          // 4. Danh sách vuốt thẻ tiệm ở phía dưới bản đồ (UC-03)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: ShopCarousel(
              shops: _filteredShops,
              selectedShopId: _selectedShopId,
              onShopSelected: (shop) {
                setState(() => _selectedShopId = shop.id);
                _animateCameraTo(LatLng(shop.latitude, shop.longitude));
                _openShopDetail(shop);
              },
              onCall: (shop) => CallHelper.makeCall(context, shop.phone),
              onNavigate: _onNavigateToShop,
              onExpandRadius: () {
                setState(() => _selectedRadius = 10000);
                _fetchNearbyShops();
              },
            ),
          ),

          // 5. Nút SOS khẩn cấp đặt phía trên carousel, không che thẻ tiệm
          Positioned(
            left: 16,
            bottom: 176,
            child: FloatingActionButton.extended(
              heroTag: 'sos_fab',
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              onPressed: _openSosScreen,
              icon: const Icon(Icons.sos),
              label: const Text(
                'CỨU HỘ SOS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 6. Nút định vị GPS "Vị trí của tôi"
          Positioned(
            right: 16,
            bottom: 180,
            child: FloatingActionButton.small(
              heroTag: 'my_location_fab',
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E88E5),
              onPressed: () => _animateCameraTo(_currentLocation),
              tooltip: 'Vị trí của tôi',
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
