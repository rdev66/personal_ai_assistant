import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<List<Video>> searchYoutubeVideos(String query) async {
  final YoutubeExplode yt = YoutubeExplode();
  try {
    debugPrint('searching youtube for $query');
    final result = await yt.search.search(query);
    debugPrint('searchYoutubeVideos: ${result.length}');
    return result;
  } catch (e) {
    debugPrint(e.toString());
    return List.empty();
  } finally {
    yt.close();
  }
}
