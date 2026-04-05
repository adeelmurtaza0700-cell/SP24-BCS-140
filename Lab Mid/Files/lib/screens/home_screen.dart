import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task_item.dart';
import '../widgets/task_form_sheet.dart';
import 'completed_tasks_screen.dart';
import 'repeated_tasks_screen.dart';
import 'settings_screen.dart';
import 'today_tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final TaskController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _showCompletedTab() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayTasksScreen(
        controller: widget.controller,
        onTaskCompleted: _showCompletedTab,
      ),
      CompletedTasksScreen(controller: widget.controller),
      RepeatedTasksScreen(
        controller: widget.controller,
        onTaskCompleted: _showCompletedTab,
      ),
      SettingsScreen(controller: widget.controller),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[_currentIndex],
      floatingActionButton: _currentIndex == 3
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openTaskSheet(context),
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('New Task'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.done_all_outlined),
            selectedIcon: Icon(Icons.done_all),
            label: 'Completed',
          ),
          NavigationDestination(
            icon: Icon(Icons.repeat_outlined),
            selectedIcon: Icon(Icons.repeat),
            label: 'Repeated',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Future<void> _openTaskSheet(BuildContext context, [TaskItem? existing]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskFormSheet(
        task: existing,
        onSubmit: (task) async {
          if (existing == null) {
            await widget.controller.addTask(task);
          } else {
            await widget.controller.updateTask(task);
          }

          if (!context.mounted) {
            return;
          }

          Navigator.of(context).pop();
        },
      ),
    );
  }
}
