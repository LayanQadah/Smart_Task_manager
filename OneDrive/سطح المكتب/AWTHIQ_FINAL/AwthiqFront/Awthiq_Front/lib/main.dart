import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'widgets/splash_screen.dart';
import 'loginSignin/reset_password_from_link_page.dart';
import 'admin/admin_login_page.dart';

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

void main() {
  final token = Uri.base.queryParameters['reset_token'];
  final path  = Uri.base.path;

  Widget home;
  if (token != null && token.isNotEmpty) {
    home = ResetPasswordFromLinkPage(token: token);
  } else if (path == '/aw-admin') {
    home = const AdminLoginPage();
  } else {
    home = SplashScreen();
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: home,
    scrollBehavior: const _AppScrollBehavior(),
    theme: ThemeData(
      scrollbarTheme: const ScrollbarThemeData(
        thumbVisibility: WidgetStatePropertyAll(true),
        thickness: WidgetStatePropertyAll(6),
        radius: Radius.circular(10),
      ),
    ),
  ));
}
