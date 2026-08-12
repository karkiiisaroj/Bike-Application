import '../models/journal_post_model.dart';
import 'api_client.dart';

class JournalService {
  static Future<List<JournalPost>> fetchPosts() async {
    final data = await ApiClient.get('/journal/posts/', auth: false);
    final list = data['data'] as List? ?? [];
    return list
        .map((e) => JournalPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<JournalPost> fetchPost(String slug) async {
    final data = await ApiClient.get('/journal/posts/$slug/', auth: false);
    return JournalPost.fromJson(data);
  }
}
