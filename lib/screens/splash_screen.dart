import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.beige,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LogoHeader(),
              SizedBox(height: 28),
              Text(
                'Выезды гостей',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.blue,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'служебное приложение',
                style: TextStyle(fontSize: 18, color: AppColors.deepBlue),
              ),
              SizedBox(height: 24),
              LinearProgressIndicator(minHeight: 6),
              SizedBox(height: 28),
              Text(
                appMotto,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.gray),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
