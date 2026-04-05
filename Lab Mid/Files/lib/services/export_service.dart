import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/task_item.dart';

class ExportService {
  ExportService._();

  static final ExportService instance = ExportService._();

  Future<File> exportCsv(List<TaskItem> tasks) async {
    final rows = <List<dynamic>>[
      [
        'Title',
        'Description',
        'Category',
        'Priority',
        'Due Date',
        'Completed',
        'Repeat',
        'Progress',
      ],
      ...tasks.map(
        (task) => [
          task.title,
          task.description,
          task.category,
          task.priority.name,
          task.dueDate.toIso8601String(),
          task.isCompleted ? 'Yes' : 'No',
          task.repeatType.name,
          '${(task.progress * 100).round()}%',
        ],
      ),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final file = await _createFile('taskflow_export.csv');
    await file.writeAsString(csv);
    return file;
  }

  Future<File> exportPdf(List<TaskItem> tasks) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('TaskFlow Export'),
          ),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Title',
              'Category',
              'Priority',
              'Due',
              'Progress',
            ],
            data: tasks
                .map(
                  (task) => [
                    task.title,
                    task.category,
                    task.priority.name,
                    task.dueDate.toString(),
                    '${(task.progress * 100).round()}%',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    final file = await _createFile('taskflow_export.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> shareFile(File file, String subject) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: subject,
      ),
    );
  }

  Future<void> emailTasks(List<TaskItem> tasks) async {
    final body = tasks
        .map(
          (task) =>
              '- ${task.title} | ${task.category} | ${task.dueDate.toLocal()} | ${task.isCompleted ? 'Completed' : 'Pending'}',
        )
        .join('\n');

    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': 'TaskFlow task export',
        'body': body,
      },
    );

    await launchUrl(uri);
  }

  Future<File> _createFile(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportsDir = Directory('${directory.path}/exports');
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }

    return File('${exportsDir.path}/$name');
  }
}
