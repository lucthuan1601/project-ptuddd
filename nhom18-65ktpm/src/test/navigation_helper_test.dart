import 'package:flutter_test/flutter_test.dart';
import 'package:ketnoitinhnguyenvienxemay/features/navigation/navigation_helper.dart';

void main() {
  group('NavigationHelper - UC-06', () {
    test('formatDistance định dạng mét và km chính xác', () {
      expect(NavigationHelper.formatDistance(350), '350 m');
      expect(NavigationHelper.formatDistance(999), '999 m');
      expect(NavigationHelper.formatDistance(1000), '1.0 km');
      expect(NavigationHelper.formatDistance(2540), '2.5 km');
      expect(NavigationHelper.formatDistance(10200), '10.2 km');
    });

    test('formatDuration định dạng phút và giờ chính xác', () {
      expect(NavigationHelper.formatDuration(5), '5 phút');
      expect(NavigationHelper.formatDuration(59), '59 phút');
      expect(NavigationHelper.formatDuration(60), '1 giờ');
      expect(NavigationHelper.formatDuration(75), '1 giờ 15 phút');
      expect(NavigationHelper.formatDuration(120), '2 giờ');
    });

    test('estimateMotorbikeMinutes trả về tối thiểu 1 phút', () {
      expect(NavigationHelper.estimateMotorbikeMinutes(0), 1);
      expect(NavigationHelper.estimateMotorbikeMinutes(100), 1);
      // 5km chim bay * 1.25 = 6.25km đường; 6.25 / 28 * 60 ~= 14 phút
      final mins = NavigationHelper.estimateMotorbikeMinutes(5000);
      expect(mins, inInclusiveRange(12, 16));
    });

    test('parseOsrmRoute giải mã GeoJSON hợp lệ và xử lý dữ liệu lỗi', () {
      final route = NavigationHelper.parseOsrmRoute({
        'routes': [
          {
            'distance': 2450.5,
            'duration': 310,
            'geometry': {
              'type': 'LineString',
              'coordinates': [
                [105.8542, 21.0285],
                [105.8600, 21.0310],
                [105.8650, 21.0350],
              ],
            },
          },
        ],
      });

      expect(route, isNotNull);
      expect(route!.isRoadRoute, isTrue);
      expect(route.points.length, 3);
      expect(route.points.first.latitude, closeTo(21.0285, 1e-6));
      expect(route.points.first.longitude, closeTo(105.8542, 1e-6));
      expect(route.distanceMeters, closeTo(2450.5, 1e-3));
      expect(route.durationMinutes, 6);

      expect(NavigationHelper.parseOsrmRoute({'routes': []}), isNull);
      expect(NavigationHelper.parseOsrmRoute({}), isNull);
    });
  });
}
