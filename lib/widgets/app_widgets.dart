import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../theme/app_theme.dart';

class DiluchLogo extends StatelessWidget {
  const DiluchLogo({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    final scale = height / 230;
    return SizedBox(
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 210,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: const [
                  Positioned(left: 18, child: _LogoCircle(kind: 0)),
                  Positioned(left: 73, child: _LogoCircle(kind: 1)),
                  Positioned(left: 128, child: _LogoCircle(kind: 2)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ДИЛУЧ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.blue,
                fontSize: 54,
                height: 0.9,
                fontWeight: FontWeight.w900,
                letterSpacing: -2.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'САНАТОРНО-КУРОРТНЫЙ\nКОМПЛЕКС',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.blue,
                fontSize: 13,
                height: 1.25,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '★ ★ ★',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.blue,
                fontSize: 18 * scale.clamp(0.85, 1.1),
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoCircle extends StatelessWidget {
  const _LogoCircle({required this.kind});

  final int kind;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: switch (kind) {
              0 => const [Color(0xFF19285E), Color(0xFF32B6D2)],
              1 => const [Color(0xFF8EE5EF), Color(0xFFFFD06F)],
              _ => const [Color(0xFFFF9F4A), Color(0xFF91DCA3)],
            },
          ),
        ),
        child: CustomPaint(painter: _LogoCirclePainter(kind)),
      ),
    );
  }
}

class _LogoCirclePainter extends CustomPainter {
  const _LogoCirclePainter(this.kind);

  final int kind;

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withValues(alpha: 0.78);
    final blue = Paint()..color = AppColors.blue.withValues(alpha: 0.28);
    final green = Paint()..color = const Color(0xFF61B978).withValues(alpha: 0.75);
    final sun = Paint()..color = const Color(0xFFFFD46A).withValues(alpha: 0.9);

    if (kind == 0) {
      final star = Paint()..color = const Color(0xFFFFE27A);
      for (final offset in const [Offset(18, 20), Offset(33, 15), Offset(45, 30)]) {
        canvas.drawCircle(offset, 2.2, star);
      }
      final path = Path()
        ..moveTo(0, size.height * .70)
        ..quadraticBezierTo(size.width * .35, size.height * .58, size.width, size.height * .70)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, blue);
    } else if (kind == 1) {
      final wave = Path()
        ..moveTo(0, 26)
        ..cubicTo(12, 36, 24, 18, 36, 28)
        ..cubicTo(48, 38, 58, 24, 64, 28)
        ..lineTo(64, 64)
        ..lineTo(0, 64)
        ..close();
      canvas.drawPath(wave, white);
      final sea = Path()
        ..moveTo(0, 38)
        ..quadraticBezierTo(20, 30, 40, 38)
        ..quadraticBezierTo(52, 43, 64, 36)
        ..lineTo(64, 64)
        ..lineTo(0, 64)
        ..close();
      canvas.drawPath(sea, blue);
    } else {
      canvas.drawCircle(const Offset(26, 29), 13, sun);
      final mountains = Path()
        ..moveTo(0, 46)
        ..lineTo(22, 28)
        ..lineTo(38, 42)
        ..lineTo(59, 24)
        ..lineTo(64, 28)
        ..lineTo(64, 64)
        ..lineTo(0, 64)
        ..close();
      canvas.drawPath(mountains, green);
    }
  }

  @override
  bool shouldRepaint(covariant _LogoCirclePainter oldDelegate) => oldDelegate.kind != kind;
}

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: compact ? 330 : 520),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 18 : 24,
            vertical: compact ? 14 : 22,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(compact ? 24 : 32),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: DiluchLogo(height: compact ? 96 : 166),
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
