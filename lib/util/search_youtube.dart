import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<List<String>> searchYoutube(String query) async {
  final YoutubeExplode yt = YoutubeExplode();
  final VideoSearchList streamInfo;
  try {
    //final streamInfo = await yt.videos.streamsClient.getManifest('fRh_vgS2dFE');
    streamInfo = await yt.search.search(query);

    debugPrint(streamInfo.toString());

    // Close the YoutubeExplode's http client.
    yt.close();
    return streamInfo.map((result) => result.title).toList();
  } catch (e) {
    debugPrint(e.toString());
    return List.empty();
  }
}
