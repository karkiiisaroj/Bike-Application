import '../data/story_local_data.dart' as local;
import '../models/story_entry.dart';
import 'api_client.dart';

class StoryService {
  /// Tries the backend first; falls back to the bundled local list on
  /// any failure (offline, backend not deployed yet, etc.) so the
  /// screen never breaks — this is the "easy to connect later" seam.
  static Future<List<StoryEntry>> fetchStoryEntries() async {
    try {
      final data = await ApiClient.get('/story/entries/', auth: false);
      final list = (data['results'] as List)
          .map((e) => StoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      return list.isNotEmpty ? list : local.storyEntries;
    } catch (_) {
      return local.storyEntries;
    }
  }
}
