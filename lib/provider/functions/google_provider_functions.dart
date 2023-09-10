import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_continuous_none/provider/google_speech_provider.dart';
import 'package:speech_continuous_none/provider/gpt_response_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void processYoutubeContent(BuildContext context, Video selectedVideo) {

  Provider.of<GptResponseProvider>(context, listen: false).clearGPTResponse();
  Provider.of<GoogleSpeechProvider>(context, listen: false).processYoutubeContent(selectedVideo);

  ScaffoldMessenger.of(context)
    .showSnackBar(const SnackBar(content: Text('Generating transcript...')));
}