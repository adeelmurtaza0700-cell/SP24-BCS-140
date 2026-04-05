import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';

class SummaryHeader extends StatelessWidget {
  const SummaryHeader({super.key, required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    final cards = [
      ('Today', controller.todayTasks.length.toString(), Icons.today_rounded),
      ('Done', '${controller.completionRate}%', Icons.auto_graph_rounded),
      (
        'Streak',
        controller.streakCount.toString(),
        Icons.local_fire_department_rounded,
      ),
    ];

    return SizedBox(
      height: 102,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Container(
            width: 132,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.28),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(card.$3, size: 22),
                Text(
                  card.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        height: 1,
                      ),
                ),
                Text(
                  card.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1,
                      ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemCount: cards.length,
      ),
    );
  }
}
