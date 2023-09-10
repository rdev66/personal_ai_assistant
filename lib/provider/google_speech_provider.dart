import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'package:googleapis/speech/v1.dart' as speech;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../util/download_from_youtube.dart';
import '../util/upload_to_cloud.dart';

class GoogleSpeechProvider extends ChangeNotifier {
  late speech.SpeechApi speechApi;

  var googleSpeechTranscript = "";

  GoogleSpeechProvider() {
    initSpeechApi();
  }

  Future<void> initSpeechApi() async {
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
        await rootBundle.loadString('assets/rdev_service_account.json'));

    final httpClient = await clientViaServiceAccount(
        serviceAccountCredentials, [speech.SpeechApi.cloudPlatformScope]);

    speechApi = speech.SpeechApi(httpClient);
  }

  Future<String?> _sendForRecognition(String storageUrl, File file) async {
    final longRunningRecognizeRequest = speech.LongRunningRecognizeRequest(
        config: speech.RecognitionConfig(
            audioChannelCount: 2,
            enableAutomaticPunctuation: true,
            encoding: "WEBM_OPUS",
            sampleRateHertz: 48000,
            languageCode: "en-US"),
        audio: speech.RecognitionAudio(
          // Can be content or gs uri
          //  content:
          uri: storageUrl,
        ));

    speech.Operation op = await speechApi.speech
        .longrunningrecognize(longRunningRecognizeRequest);

    return op.name;
  }

  Future<String> _fetchTranscribeOperationResultsApi(
      String operationName) async {
    var conversation = "";

    debugPrint("fetchTranscribeOperationResultsApi: $operationName");

    var op = await speechApi.operations.get(operationName);

    while (op.done != true) {
      await Future.delayed(const Duration(seconds: 1));
      debugPrint("Waiting for transcript operation to complete");
      op = await speechApi.operations.get(operationName);
    }
    var results = (op.response as Map<String, dynamic>)['results'];

    if (results.isNotEmpty) {
      //First alternative higher confidence
      for (var res in results) {
        conversation += res['alternatives']
            .map((alternative) => alternative['transcript'])
            .join('');
      }
    } else {
      return "Empty transcription result!";
    }
    return conversation;
  }

  processYoutubeContent(Video selectedVideo) async {
    var saveFile = await downloadcontentFromYoutube(selectedVideo);
    var storageUrl = await uploadContentToGoogleCloud(selectedVideo);

    final String? opName = await _sendForRecognition(storageUrl, saveFile);

    if (opName == null) {
      debugPrint("No operation generated for transcript");
      return;
    }
    googleSpeechTranscript = await _fetchTranscribeOperationResultsApi(opName);

    notifyListeners();
  }


  void clearGoogleSpeechTranscript() {
    googleSpeechTranscript = '';
    //
    notifyListeners();
  }
}
