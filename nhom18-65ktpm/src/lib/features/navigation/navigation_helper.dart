import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

/// Hỗ trợ UC-06: Chỉ đường (Navigation) - tính toán khoảng cách và thời gian.
class NavigationHelper {
  NavigationHelper._();

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
