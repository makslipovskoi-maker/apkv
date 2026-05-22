import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../theme/app_theme.dart';

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: compact ? 300 : 520),
          padding: EdgeInsets.all(compact ? 12 : 18),
          decoration: BoxDecoration(
            color: AppColors.midnight,
            borderRadius: BorderRadius.circular(compact ? 22 : 30),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Image.asset(
            'assets/logo.jpg',
            height: compact ? 74 : 116,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const _FallbackLogo(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          appTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.deepBlue,
            fontSize: compact ? 21 : 30,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 8),
          const Text(
            appSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: AppColors.gray,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo();
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.spa_outlined, color: AppColors.turquoise, size: 46),
        SizedBox(height: 8),
        Text(
          'ДИЛУЧ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.title, required this.child, this.actions});
  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: Container(
        decoration: const BoxDecoration(gradient: appBackgroundGradient),
        child: SafeArea(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}

class PremiumHeroCard extends StatelessWidget {
  const PremiumHeroCard({super.key, required this.title, required this.subtitle, this.trailing});
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: brandHeroGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.22),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ДИЛУЧ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xDDEFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 14), trailing!],
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.text, this.icon = Icons.inbox_outlined});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: AppColors.blue),
              const SizedBox(height: 14),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    final foreground = color.computeLuminance() > 0.55 ? AppColors.deepBlue : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(
        status,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w900, fontSize: 14),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key, this.icon});
  final String label;
  final String? value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final display = value == null || value!.trim().isEmpty ? '—' : value!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.lightTurquoise,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.blue),
            ),
            const SizedBox(width: 10),
          ],
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: AppColors.gray, fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              display,
              style: const TextStyle(fontSize: 17, color: AppColors.deepBlue, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class BigActionButton extends StatelessWidget {
  const BigActionButton({super.key, required this.label, required this.onPressed, this.color, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ElevatedButton.icon(
        icon: Icon(icon ?? Icons.check_circle_outline, size: 28),
        label: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text(label)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.blue,
          minimumSize: const Size.fromHeight(64),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

void showAppMessage(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}
