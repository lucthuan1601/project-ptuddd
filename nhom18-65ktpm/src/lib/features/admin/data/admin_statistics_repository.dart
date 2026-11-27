import '../../../core/supabase_client.dart';
import '../../../core/supabase_errors.dart';
import '../../../repositories/auth_repository.dart';

enum StatsPeriod { sevenDays, thirtyDays, currentMonth }

extension StatsPeriodLabel on StatsPeriod {
  String get label => switch (this) {
    StatsPeriod.sevenDays => '7 ngày',
    StatsPeriod.thirtyDays => '30 ngày',
    StatsPeriod.currentMonth => 'Tháng hiện tại',
  };

  DateTime startDate(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      StatsPeriod.sevenDays => today.subtract(const Duration(days: 6)),
      StatsPeriod.thirtyDays => today.subtract(const Duration(days: 29)),
      StatsPeriod.currentMonth => DateTime(now.year, now.month, 1),
    };
  }
}

class StatsDay {
  const StatsDay({
    required this.date,
    required this.sosCount,
    required this.shopAccepted,
    required this.volunteerAccepted,
  });

  final DateTime date;
  final int sosCount;
  final int shopAccepted;
  final int volunteerAccepted;
}

class AdminStatisticsSnapshot {
  const AdminStatisticsSnapshot({
    required this.period,
    required this.startDate,
    required this.userCount,
    required this.repairShopCount,
    required this.gasStationCount,
    required this.volunteerCount,
    required this.sosCount,
    required this.completedCount,
    required this.days,
  });

  final StatsPeriod period;
  final DateTime startDate;
  final int userCount;
  final int repairShopCount;
  final int gasStationCount;
  final int volunteerCount;
  final int sosCount;
  final int completedCount;
  final List<StatsDay> days;

  int get shopCount => repairShopCount + gasStationCount;
  double get completionRate => sosCount == 0 ? 0 : completedCount / sosCount;
  bool get isEmpty =>
      userCount == 0 && shopCount == 0 && volunteerCount == 0 && sosCount == 0;

  String toCsv() {
    final lines = <String>[
      'ngay,so_sos,tiem_tiep_nhan,tnv_tiep_nhan',
      for (final day in days)
        '${_dateKey(day.date)},${day.sosCount},${day.shopAccepted},${day.volunteerAccepted}',
      '',
      'chi_so,so_luong',
      'nguoi_dung_moi,$userCount',
      'tiem_sua_xe_moi,$repairShopCount',
      'cay_xang_moi,$gasStationCount',
      'tnv_moi,$volunteerCount',
      'sos_moi,$sosCount',
      'sos_hoan_thanh,$completedCount',
    ];
    return lines.join('\r\n');
  }
}

String _dateKey(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

class AdminStatisticsRepository {
  Future<void> _requireAdmin() async {
    final id = supabase.auth.currentUser?.id;
    if (id == null) {
      throw const AppException('Bạn cần đăng nhập.');
    }
    final row = await supabase
        .from('users')
        .select('role,status')
        .eq('id', id)
        .maybeSingle();
    if (row == null || row['role'] != 'admin' || row['status'] != 'active') {
      throw const AppException('Bạn không có quyền xem thống kê.');
    }
  }

  Future<AdminStatisticsSnapshot> load(StatsPeriod period) {
    return guardSupabase(() async {
      await _requireAdmin();
      final now = DateTime.now();
      final start = period.startDate(now);
      final startIso = start.toUtc().toIso8601String();
      final endIso = now.toUtc().toIso8601String();

      final results = await Future.wait<List<Map<String, dynamic>>>([
        supabase
            .from('users')
            .select('id,created_at')
            .gte('created_at', startIso)
            .lte('created_at', endIso),
        supabase
            .from('shops')
            .select('id,category,created_at')
            .gte('created_at', startIso)
            .lte('created_at', endIso),
        supabase
            .from('volunteer_profiles')
            .select('id,created_at')
            .gte('created_at', startIso)
            .lte('created_at', endIso),
        supabase
            .from('sos_requests')
            .select(
              'id,status,created_at,accepted_shop_id,accepted_volunteer_id',
            )
            .gte('created_at', startIso)
            .lte('created_at', endIso),
      ]);
      final userRows = results[0];
      final shopRows = results[1];
      final volunteerRows = results[2];
      final sosRows = results[3];

    final totals = <String, int>{};
    final shops = <String, int>{};
    final volunteers = <String, int>{};
    for (final row in sosRows) {
      final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
      if (createdAt == null) {
        continue;
      }
      final key = _dateKey(createdAt.toLocal());
      totals[key] = (totals[key] ?? 0) + 1;
      if (row['accepted_shop_id'] != null) {
        shops[key] = (shops[key] ?? 0) + 1;
      }
      if (row['accepted_volunteer_id'] != null) {
        volunteers[key] = (volunteers[key] ?? 0) + 1;
      }
    }

    final days = <StatsDay>[];
    for (
      var day = start;
      !day.isAfter(DateTime(now.year, now.month, now.day));
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      final key = _dateKey(day);
      days.add(
        StatsDay(
          date: day,
          sosCount: totals[key] ?? 0,
          shopAccepted: shops[key] ?? 0,
          volunteerAccepted: volunteers[key] ?? 0,
        ),
      );
    }

    return AdminStatisticsSnapshot(
      period: period,
      startDate: start,
      userCount: userRows.length,
      repairShopCount: shopRows
          .where((row) => row['category'] == 'repair_shop')
          .length,
      gasStationCount: shopRows
          .where((row) => row['category'] == 'gas_station')
          .length,
      volunteerCount: volunteerRows.length,
      sosCount: sosRows.length,
      completedCount: sosRows
          .where((row) => row['status'] == 'completed')
          .length,
      days: days,
    );
    });
  }
}
