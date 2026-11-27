import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// Thông tin tuyến đường bộ thực tế (từ OSRM) hoặc đường thẳng ước tính (UC-06).
class RouteInfo {
  const RouteInfo({
    required this.points,
    required this.distanceMeters,
    required this.durationMinutes,
    required this.isRoadRoute,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final int durationMinutes;
  final bool isRoadRoute;
}

/// Hỗ trợ UC-06: Chỉ đường (Navigation) trong và ngoài ứng dụng.
class NavigationHelper {
  NavigationHelper._();

  /// Phân tích phản hồi JSON của OSRM Route API (GeoJSON).
  static RouteInfo? parseOsrmRoute(Map<String, dynamic> json) {
    final routes = json['routes'];
    if (routes is! List || routes.isEmpty) return null;
    final first = routes.first;
    if (first is! Map<String, dynamic>) return null;

    final geometry = first['geometry'];
    if (geometry is! Map<String, dynamic>) return null;
    final coords = geometry['coordinates'];
    if (coords is! List || coords.length < 2) return null;

    final points = <LatLng>[];
    for (final item in coords) {
      if (item is List && item.length >= 2 && item[0] is num && item[1] is num) {
        // GeoJSON trả [longitude, latitude]
        points.add(LatLng((item[1] as num).toDouble(), (item[0] as num).toDouble()));
      }
    }
    if (points.length < 2) return null;

    final distanceMeters = (first['distance'] as num?)?.toDouble() ?? 0;
    final durationSeconds = (first['duration'] as num?)?.toDouble() ?? 0;
    final minutes = durationSeconds > 0
        ? math.max(1, (durationSeconds / 60).ceil())
        : estimateMotorbikeMinutes(distanceMeters);

    return RouteInfo(
      points: points,
      distanceMeters: distanceMeters,
      durationMinutes: minutes,
      isRoadRoute: true,
    );
  }

  /// Lấy tuyến đường bộ thực tế từ dịch vụ OSRM công khai (miễn phí, không cần key).
  /// Trả `null` nếu mạng yếu hoặc timeout để màn hình chuyển sang đường thẳng dự phòng.
  static Future<RouteInfo?> fetchRoadRoute({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '$originLng,$originLat;$destinationLng,$destinationLat'
      '?overview=full&geometries=geojson',
    );

    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.getUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.userAgentHeader, 'FixMotoApp/1.0');
      final response = await request.close().timeout(timeout);
      if (response.statusCode != HttpStatus.ok) return null;

      final body = await response.transform(utf8.decoder).join().timeout(timeout);
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      return parseOsrmRoute(decoded);
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  /// Mở ứng dụng Google Maps ngoài để điều hướng rẽ theo từng chặng (Turn-by-turn navigation)
  static Future<bool> openExternalGoogleMaps({
    required double destinationLat,
    required double destinationLng,
    BuildContext? context,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&travelmode=driving',
    );

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể mở ứng dụng bản đồ Google Maps.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return false;
      }
    } catch (_) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi mở bản đồ bên ngoài.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }

  /// Tính khoảng cách giữa 2 tọa độ (mét)
  static double calculateDistanceMeters({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Định dạng khoảng cách thân thiện: "450 m" hoặc "3.2 km"
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }

  /// Ước tính thời gian di chuyển bằng xe máy trong đô thị (~30 km/h)
  /// Cộng thêm hệ số đường cong thực tế ~1.25 so với khoảng cách chim bay
  static int estimateMotorbikeMinutes(double straightMeters) {
    final roadMeters = straightMeters * 1.25;
    final km = roadMeters / 1000.0;
    // Tốc độ trung bình 28 km/h trong nội đô
    final hours = km / 28.0;
    final minutes = (hours * 60).ceil();
    return math.max(1, minutes);
  }

  /// Định dạng chuỗi thời gian di chuyển: "5 phút", "1 giờ 10 phút"
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes phút';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours giờ';
    }
    return '$hours giờ $remainingMinutes phút';
  }
}
