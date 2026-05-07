import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/supabase_service.dart';
import '../models/submission.dart';
import '../widgets/submission_form.dart';
import '../widgets/submission_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Submission> _submissions = [];
  bool _isLoading = true;
  Submission? _editingSubmission;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabaseService.fetchSubmissions();
      setState(() => _submissions = data);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onEdit(Submission submission) {
    setState(() => _editingSubmission = submission);
  }

  void _clearEdit() {
    setState(() => _editingSubmission = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CSC303 // QUIZ NO. 3',
                        style: theme.textTheme.labelSmall!.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'SUBMISSION\nMANAGER',
                        style: theme.textTheme.displayLarge!.copyWith(
                          height: 0.9,
                        ),
                      ),
                    ],
                  ),
                  const StatusIndicator(),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(color: Color(0xFF334155)),
              const SizedBox(height: 32),

              // Responsive Content
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: _buildFormSection(theme),
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            flex: 6,
                            child: _buildListSection(theme),
                          ),
                        ],
                      );
                    } else {
                      return ListView(
                        children: [
                          _buildFormSection(theme),
                          const SizedBox(height: 40),
                          _buildListSection(theme),
                        ],
                      );
                    }
                  },
                ),
              ),

              // Footer
              const SizedBox(height: 24),
              const Footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          number: '01',
          title: _editingSubmission == null ? 'Create Entry' : 'Modify Record',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF1E293B), width: 4),
          ),
          child: SubmissionFormWidget(
            submission: _editingSubmission,
            onSuccess: () {
              _clearEdit();
              _refreshData();
            },
            onCancel: _editingSubmission != null ? _clearEdit : null,
          ),
        ),
      ],
    );
  }

  Widget _buildListSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionHeader(number: '02', title: 'Live Records', isDark: true),
            Text(
              '${_submissions.length} Total Entries',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: SubmissionListWidget(
              submissions: _submissions,
              isLoading: _isLoading,
              onEdit: _onEdit,
              onDelete: (id) async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF0F172A),
                    title: const Text(
                      'Confirm Deletion',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                    content: Text(
                      'Are you sure you want to delete this record? This action cannot be undone.',
                      style: const TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w900),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'DELETE',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await _supabaseService.deleteSubmission(id);
                  _refreshData();
                }
              },

            ),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String number;
  final String title;
  final bool isDark;

  const SectionHeader({
    super.key,
    required this.number,
    required this.title,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          color: isDark ? const Color(0xFF334155) : const Color(0xFF3ECF8E),
          child: Text(
            number,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 6,
              backgroundColor: Color(0xFF3ECF8E),
            ),
            SizedBox(width: 12),
            Text(
              'SUPABASE CONNECTED',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Text(
          'CLO-3: Full CRUD Integration',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      ],
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Divider(color: Color(0xFF334155)),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FooterItem(label: 'Engine: Flutter 3.x + Supabase'),
                SizedBox(width: 24),
                FooterItem(label: 'ID: SUPABASE_FLUTTER_V2'),
              ],
            ),
            Row(
              children: [
                Text(
                  '10 MARKS',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class FooterItem extends StatelessWidget {
  final String label;
  const FooterItem({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 3, backgroundColor: Color(0xFF475569)),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
