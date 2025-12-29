import 'package:echostream/services/liked_songs_service.dart';
import 'package:flutter/foundation.dart';

class LikedSongsProvider with ChangeNotifier {
  final LikedSongsService _service = LikedSongsService();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await _service.init();
    _isInitialized = true;
    notifyListeners();
  }

  bool isLiked(int trackId) => _service.isLiked(trackId);

  Future<void> toggleLike(int trackId) async {
    await _service.toggleLike(trackId);
    notifyListeners();
  }

  Set<int> get likedSongs => _service.likedSongs;

  int get count => _service.count;
}
