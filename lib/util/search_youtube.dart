import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<List<Video>> searchYoutubeVideos(String query) async {
  final YoutubeExplode yt = YoutubeExplode();
  try {
    if (kDebugMode) {
      print('searching youtube for $query');
    }
    //final result = await yt.videos.streamsClient.getManifest('fRh_vgS2dFE');
    //var result = await yt.search.search(query);
    // Close the YoutubeExplode's http client.

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
