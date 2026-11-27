import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ketnoitinhnguyenvienxemay/core/theme.dart';
import 'package:ketnoitinhnguyenvienxemay/features/auth/screens/login_screen.dart';
import 'package:ketnoitinhnguyenvienxemay/features/auth/screens/register_screen.dart';

void main() {
  testWidgets('LoginScreen hiển thị form và báo lỗi khi bỏ trống', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: buildAppTheme(), home: const LoginScreen()),
    );

    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);

    await tester.tap(find.text('Đăng nhập'));
    await tester.pump();

    expect(find.text('Vui lòng nhập email'), findsOneWidget);
    expect(find.text('Mật khẩu tối thiểu 6 ký tự'), findsOneWidget);
  });

  testWidgets('RegisterScreen kiểm tra dữ liệu và không cho chọn vai trò admin', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: buildAppTheme(), home: const RegisterScreen()),
    );

    expect(find.text('Đăng ký tài khoản'), findsOneWidget);
    expect(find.text('Quản trị viên'), findsNothing);

    await tester.tap(find.text('Đăng ký'));
    await tester.pump();

    expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
    expect(find.text('Vui lòng nhập số điện thoại'), findsOneWidget);
    expect(find.text('Vui lòng nhập email'), findsOneWidget);
    expect(find.text('Mật khẩu tối thiểu 6 ký tự'), findsOneWidget);
  });
}
