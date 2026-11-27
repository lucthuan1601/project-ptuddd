import 'package:flutter/material.dart';

import 'admin_management_screen.dart';
import 'admin_statistics_screen.dart';

class AdminWorkspaceScreen extends StatelessWidget {
  const AdminWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản trị viên'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.admin_panel_settings), text: 'Quản lý'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Thống kê'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [AdminManagementScreen(), AdminStatisticsScreen()],
        ),
      ),
    );
  }
}
