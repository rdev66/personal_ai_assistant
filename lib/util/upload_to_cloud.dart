import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<String> uploadToCloud(Video selectedVideo, BuildContext context) async {
  final YoutubeExplode yt = YoutubeExplode();

  // Create a storage reference from our app
  final storageRef = FirebaseStorage.instance.ref();

  final StreamManifest manifest =
      await yt.videos.streamsClient.getManifest(selectedVideo.id);

  //Get audio only for transcription
  final StreamInfo audioStreamInfo = manifest.audioOnly.withHighestBitrate();

  Directory file = await getApplicationCacheDirectory();

  // Open a file for reading.
  var readFile = File(
      '${file.path}/${selectedVideo.title}.${audioStreamInfo.container.name}');

  // Create a reference to file in storage
  try {
    final uploadTask = storageRef
        .child(
            "audios/${selectedVideo.title}.${audioStreamInfo.container.name}")
        .putFile(readFile);

    uploadTask.snapshotEvents.listen((taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          // ...
          break;
        case TaskState.paused:
          // ...
          break;
        case TaskState.success:
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Upload Success!")));
          if (kDebugMode) {
            print("Success");
          }
          break;
        case TaskState.canceled:
          // ...
          break;
        case TaskState.error:
          if (kDebugMode) {
            print("Error");
          }
          break;
      }
    });

    final taskSnapshot =
        await uploadTask.whenComplete(() => print("Upload complete"));

    ///String url = await taskSnapshot.ref.getDownloadURL();
    return "gs://${storageRef.bucket}/${taskSnapshot.ref.fullPath}";


  } on FirebaseException catch (e) {
    if (kDebugMode) {
      print(e);
    }
    return "ERROR";
  }
}
