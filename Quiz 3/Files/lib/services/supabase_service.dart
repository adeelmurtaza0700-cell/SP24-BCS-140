import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/submission.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  Future<List<Submission>> fetchSubmissions() async {
    final response = await client
        .from('submissions')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => Submission.fromJson(json)).toList();
  }

  Future<void> createSubmission(Submission submission) async {
    await client.from('submissions').insert(submission.toJson());
  }

  Future<void> updateSubmission(String id, Submission submission) async {
    await client.from('submissions').update(submission.toJson()).eq('id', id);
  }

  Future<void> deleteSubmission(String id) async {
    await client.from('submissions').delete().eq('id', id);
  }
}
