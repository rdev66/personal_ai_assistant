import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_continuous_none/provider/google_speech_provider.dart';
import '../../provider/functions/gpt_provider_functions.dart';

class YoutubeFloatingActionButtonsBar extends StatelessWidget {
  final bool isSummarizing;
  final bool speechEnabled;
  final bool isSpeechToTextListening;

  const YoutubeFloatingActionButtonsBar(
      this.isSummarizing, this.speechEnabled, this.isSpeechToTextListening,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final transcribedText =
        Provider.of<GoogleSpeechProvider>(context, listen: true)
            .googleSpeechTranscript;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        showClearButton(context, transcribedText),
        showSummarizeButton(context, transcribedText),
      ],
    );
  }

  FloatingActionButton showClearButton(context, String transcribedText) {
    return FloatingActionButton(
      onPressed: () => clearGPTResponse(context),
      backgroundColor: transcribedText.isNotEmpty ? Colors.blue : Colors.grey,
      tooltip: 'Clear',
      child: const Icon(Icons.clear),
    );
  }

  Widget showSummarizeButton(context, String transcribedText) {
    return isSummarizing
        ? const CircularProgressIndicator()
        : FloatingActionButton(
            onPressed: () => generateTranscriptSummary(context, transcribedText),
            backgroundColor:
                (transcribedText.isNotEmpty && !isSpeechToTextListening)
                    ? Colors.blue
                    : Colors.grey,
            tooltip: "Summarize",
            child: Icon(transcribedText.isNotEmpty
                ? Icons.summarize
                : Icons.comments_disabled),
          );
  }
}
