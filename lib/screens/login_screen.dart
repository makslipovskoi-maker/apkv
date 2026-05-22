import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/app_user.dart';
import '../repositories/app_repository.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'main_menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pinController = TextEditingController();
  final _repo = AppRepository();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _error = 'Введите PIN-код');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final AppUser? user = await _repo.loginByPin(pin);
      if (!mounted) return;
      if (user == null) {
        setState(() => _error = 'Неверный PIN-код');
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainMenuScreen(user: user)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Нет связи с сервером или ошибка входа');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final demoMode = !SupabaseService.instance.isConfigured;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: appBackgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    const LogoHeader(),
                    const SizedBox(height: 20),
                    const PremiumHeroCard(
                      title: 'Выезды гостей без хаоса',
                      subtitle: 'Единый служебный график для корпусов, регистратора, водителей и главного механика.',
                      trailing: Icon(Icons.directions_bus_filled_outlined, color: Colors.white, size: 46),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Служебный вход',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.deepBlue,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              appMotto,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.gray,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (demoMode) ...[
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.sand,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.orange),
                                ),
                                child: const Text(
                                  'Демо-режим без сервера\n1111 регистратор · 2222 корпус · 3333 водитель · 4444 механик · 5555 руководитель',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.deepBlue,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 22),
                            TextField(
                              controller: _pinController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 8,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 30,
                                letterSpacing: 9,
                                fontWeight: FontWeight.w900,
                                color: AppColors.deepBlue,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Введите PIN-код',
                                counterText: '',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              onSubmitted: (_) => _login(),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: _loading ? null : _login,
                              icon: _loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(strokeWidth: 3),
                                    )
                                  : const Icon(Icons.login),
                              label: Text(_loading ? 'ВХОД...' : 'ВОЙТИ В ГРАФИК'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
