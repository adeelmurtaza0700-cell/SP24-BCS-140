import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/submission.dart';

class SubmissionListWidget extends StatelessWidget {
  final List<Submission> submissions;
  final bool isLoading;
  final Function(Submission) onEdit;
  final Function(String) onDelete;

  const SubmissionListWidget({
    super.key,
    required this.submissions,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF3ECF8E)),
            SizedBox(height: 16),
            Text(
              'STREAM SYNCING...',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 12,
                letterSpacing: 2,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    if (submissions.isEmpty) {
      return const Center(
        child: Text(
          'NO LIVE RECORDS FOUND.',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
        ),
      );
    }

    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: const Color(0xFF1E293B),
          child: const Row(
            children: [
              Expanded(flex: 3, child: _HeaderLabel('FULL NAME')),
              Expanded(flex: 3, child: _HeaderLabel('CONTACT INFO')),
              Expanded(flex: 2, child: _HeaderLabel('GENDER')),
              Expanded(flex: 2, child: _HeaderLabel('ACTIONS', align: TextAlign.right)),
            ],
          ),
        ),
        // Table Body
        Flexible(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: submissions.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFF334155)),
            itemBuilder: (context, index) {
              final s = submissions[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                          Text(s.id?.substring(0, 8).toUpperCase() ?? '', style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _IconLabel(icon: LucideIcons.mail, text: s.email),
                          const SizedBox(height: 4),
                          _IconLabel(icon: LucideIcons.phone, text: s.phoneNumber, isSmall: true),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: UnconstrainedBox(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getGenderColor(s.gender).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            s.gender.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _getGenderColor(s.gender)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _ActionButton(label: 'EDIT', color: const Color(0xFF3ECF8E), onTap: () => onEdit(s)),
                          const SizedBox(width: 16),
                          _ActionButton(label: 'DELETE', color: Colors.redAccent, onTap: () => onDelete(s.id!)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getGenderColor(String gender) {
    if (gender == 'Male') return Colors.blue;
    if (gender == 'Female') return Colors.pink;
    return Colors.amber;
  }
}

class _HeaderLabel extends StatelessWidget {
  final String label;
  final TextAlign align;
  const _HeaderLabel(this.label, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: align,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: Color(0xFF64748B),
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isSmall;

  const _IconLabel({required this.icon, required this.text, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSmall ? 10 : 12,
              fontFamily: isSmall ? 'JetBrainsMono' : null,
              color: isSmall ? const Color(0xFF64748B) : Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
