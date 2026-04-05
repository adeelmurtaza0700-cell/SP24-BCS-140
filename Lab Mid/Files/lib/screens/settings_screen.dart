import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/app_settings.dart';
import '../widgets/section_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final settings = controller.settings;
        return SectionShell(
          title: 'Settings',
          subtitle:
              'Customize the experience and export your work in a few taps.',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              _SettingsCard(
                title: 'Theme Mode',
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (value) {
                    controller.updateSettings(
                      settings.copyWith(themeMode: value.first),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Accent Color',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(AppSettings.palette.length, (index) {
                    final color = AppSettings.palette[index];
                    final selected = settings.accentIndex == index;
                    return InkWell(
                      onTap: () {
                        controller.updateSettings(
                          settings.copyWith(accentIndex: index),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded, color: Colors.white)
                            : null,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Notification Sound',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'default',
                          label: Text('Default'),
                        ),
                        ButtonSegment(
                          value: 'calm_ping',
                          label: Text('Calm Ping'),
                        ),
                        ButtonSegment(
                          value: 'bright_chime',
                          label: Text('Bright Chime'),
                        ),
                      ],
                      selected: {settings.notificationSound},
                      onSelectionChanged: (value) {
                        controller.updateSettings(
                          settings.copyWith(notificationSound: value.first),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose the alert tone used for upcoming task reminders.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                title: 'Export',
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.table_chart_rounded),
                      title: const Text('Export CSV'),
                      subtitle: const Text('Share a spreadsheet-ready file'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: controller.exportCsv,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.picture_as_pdf_rounded),
                      title: const Text('Export PDF'),
                      subtitle: const Text('Create a polished document summary'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: controller.exportPdf,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Export Email'),
                      subtitle: const Text('Compose an email summary of all tasks'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: controller.exportEmail,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
