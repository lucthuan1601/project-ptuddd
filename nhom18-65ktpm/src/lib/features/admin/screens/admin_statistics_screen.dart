import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/admin_statistics_repository.dart';

class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  final _repository = AdminStatisticsRepository();
  StatsPeriod _period = StatsPeriod.thirtyDays;
  late Future<AdminStatisticsSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.load(_period);
  }

  Future<void> _reload() async {
    final next = _repository.load(_period);
    setState(() => _future = next);
    try {
      await next;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tải lại được thống kê.')),
        );
      }
    }
  }

  void _changePeriod(StatsPeriod? period) {
    if (period == null || period == _period) {
      return;
    }
    setState(() {
      _period = period;
      _future = _repository.load(period);
    });
  }

  Future<void> _copyCsv(AdminStatisticsSnapshot data) async {
    await Clipboard.setData(ClipboardData(text: data.toCsv()));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép CSV. Có thể dán vào file .csv để lưu.'),
      ),
    );
  }

  Widget _kpi(String label, String value, IconData icon) {
    return SizedBox(
      width: 155,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 10),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chart(AdminStatisticsSnapshot data) {
    final maximum = data.days.fold<int>(
      1,
      (previous, day) => day.sosCount > previous ? day.sosCount : previous,
    );
    return SizedBox(
      height: 230,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final day in data.days)
              SizedBox(
                width: 44,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${day.sosCount}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 145,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 19,
                          height: day.sosCount == 0
                              ? 2
                              : 145 * day.sosCount / maximum,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${day.date.day}/${day.date.month}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statTable(AdminStatisticsSnapshot data) {
    final activeDays = data.days.where((day) => day.sosCount > 0).toList();
    if (activeDays.isEmpty) {
      return const Text('Chưa có ca SOS nào trong khoảng thời gian này.');
    }
    return Column(
      children: [
        for (final day in activeDays)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text('${day.date.day}/${day.date.month}/${day.date.year}'),
            subtitle: Text(
              'Tiệm nhận: ${day.shopAccepted} · TNV nhận: ${day.volunteerAccepted}',
            ),
            trailing: Text('${day.sosCount} SOS'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UC-15: Thống kê hệ thống'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<AdminStatisticsSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<StatsPeriod>(
                  initialValue: _period,
                  decoration: const InputDecoration(
                    labelText: 'Khoảng thời gian',
                  ),
                  items: [
                    for (final option in StatsPeriod.values)
                      DropdownMenuItem(
                        value: option,
                        child: Text(option.label),
                      ),
                  ],
                  onChanged: _changePeriod,
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState != ConnectionState.done)
                  const Center(child: CircularProgressIndicator())
                else if (snapshot.hasError)
                  Column(
                    children: [
                      Text(
                        'Không tải được thống kê: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: _reload,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  )
                else if (data != null) ...[
                  if (data.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Không có dữ liệu trong khoảng thời gian đã chọn.',
                      ),
                    ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _kpi('Người dùng mới', '${data.userCount}', Icons.people),
                      _kpi(
                        'Tiệm sửa xe mới',
                        '${data.repairShopCount}',
                        Icons.build,
                      ),
                      _kpi(
                        'Cây xăng mới',
                        '${data.gasStationCount}',
                        Icons.local_gas_station,
                      ),
                      _kpi(
                        'TNV mới',
                        '${data.volunteerCount}',
                        Icons.volunteer_activism,
                      ),
                      _kpi('Ca SOS mới', '${data.sosCount}', Icons.sos),
                      _kpi(
                        'SOS hoàn thành',
                        '${data.completedCount}',
                        Icons.task_alt,
                      ),
                      _kpi(
                        'Tỷ lệ hoàn thành',
                        '${(data.completionRate * 100).toStringAsFixed(1)}%',
                        Icons.pie_chart,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Số yêu cầu SOS theo ngày',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  _chart(data),
                  Text(
                    'Ca SOS theo đơn vị tiếp nhận',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _statTable(data),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _copyCsv(data),
                    icon: const Icon(Icons.copy),
                    label: const Text('Sao chép dữ liệu CSV'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Số liệu trong khoảng được chọn. Dữ liệu phụ thuộc phân quyền và giới hạn trả về của Supabase. CSV được sao chép, chưa tải trực tiếp thành file.',
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
