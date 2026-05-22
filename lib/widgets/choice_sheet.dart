import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

Future<String?> showChoiceSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.deepBlue,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            for (final option in options)
              Card(
                child: ListTile(
                  title: Text(
                    option,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  trailing: const Icon(Icons.check_circle_outline),
                  onTap: () => Navigator.of(context).pop(option),
                ),
              ),
          ],
        ),
      );
    },
  );
}
