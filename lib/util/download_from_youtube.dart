  import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<File> downloadFromYoutube(Video selectedVideo) async {
    final YoutubeExplode yt = YoutubeExplode();

    final StreamManifest manifest =
        await yt.videos.streamsClient.getManifest(selectedVideo.id);

    //Get audio only for transcription
    final StreamInfo audioStreamInfo = manifest.audioOnly.withHighestBitrate();

    var stream = yt.videos.streamsClient.get(audioStreamInfo);

    // Create the message and set the cursor position.
    debugPrint(
        'Downloading ${selectedVideo.title}.${audioStreamInfo.container.name}');

    Directory file = await getApplicationCacheDirectory();

    // Open a file for writing.
    var saveFile = File(
        '${file.path}/${selectedVideo.title}.${audioStreamInfo.container.name}');

    var fileStream = saveFile.openWrite();

    // Pipe all the content of the stream into the file.
    await stream.pipe(fileStream);

    // Close the file.
    await fileStream.flush();
    await fileStream.close();

    return saveFile;
  }