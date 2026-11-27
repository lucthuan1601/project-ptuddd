import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ketnoitinhnguyenvienxemay/features/owner/screens/shop_editor_screen.dart';

void main() {
  testWidgets('UC-09: Màn hình đăng ký hiển thị trường bắt buộc', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ShopEditorScreen()));
    expect(find.text('Đăng ký tiệm'), findsOneWidget);
    expect(find.text('Tên tiệm *'), findsOneWidget);
    expect(find.text('Loại cơ sở *'), findsOneWidget);
  });
}
