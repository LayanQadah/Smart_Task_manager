import 'dart:async';
import 'package:flutter/material.dart';
import 'backgrounds.dart';
import '../services/api_service.dart';
import '../loginSignin/user_type_screen.dart';
import '../user/individual_home_page.dart';
import '../company/company_home_page.dart';
import '../trainer/trainer_home_page.dart';
import '../admin/admin_home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final loggedIn = await ApiService.isLoggedIn();
    if (!mounted) return;
    if (loggedIn) {
      final userType = await ApiService.getUserType();
      if (!mounted) return;
      Widget destination;
      if (userType == 'admin') {
        destination = const AdminHomePage();
      } else if (userType == 'company') {
        destination = CompanyHomePage();
      } else if (userType == 'institution') {
        destination = TrainingHomePage();
      } else {
        destination = IndividualHomePage();
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserTypeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SplashBackground(),
          Center(
            child: Image.asset(
              "assets/logo1.png",
              width: MediaQuery.of(context).size.width * 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
