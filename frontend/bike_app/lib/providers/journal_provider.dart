import 'package:flutter/material.dart';
import '../models/journal_post_model.dart';
import '../services/journal_service.dart';

class JournalProvider extends ChangeNotifier {
  List<JournalPost> posts = [];
  bool isLoading = false;

  Future<void> fetchPosts() async {
    isLoading = true;
    notifyListeners();
    try {
      posts = await JournalService.fetchPosts();
    } catch (e) {
      debugPrint('⚠️ fetchJournalPosts failed: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
