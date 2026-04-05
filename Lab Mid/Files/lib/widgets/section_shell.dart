import 'package:flutter/material.dart';

class SectionShell extends StatelessWidget {
  const SectionShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.header,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.18),
            Theme.of(context).scaffoldBackgroundColor,
            colors.tertiary.withValues(alpha: 0.14),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget?>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.75),
                        ),
                  ),
                ],
              ),
            ),
            header,
            Expanded(child: child),
          ].whereType<Widget>().toList(),
        ),
      ),
    );
  }
}
