import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_continuous_none/provider/gpt_response_provider.dart';

//Functions to call provider
void generateTranscriptSummary(BuildContext context, String textToSummarize) {
  Provider.of<GptResponseProvider>(context, listen: false)
      .chatComplete(textToSummarize);
}

void clearGPTResponse(BuildContext context) {
  Provider.of<GptResponseProvider>(context, listen: false).clearGPTResponse();
  ScaffoldMessenger.of(context)
    .showSnackBar(const SnackBar(content: Text('Cleared!')));
}

