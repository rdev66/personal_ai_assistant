import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class YoutubeFloatingActionButtonsBar extends StatelessWidget {

  final bool isSummarizing;
  final bool speechEnabled;
  final String transcribedText;
  final String gptResponse;
  final SpeechToText speechToText;

  final Function clearGPTResponse;
  final Function(String) chatComplete;
  final Function speak;

  const YoutubeFloatingActionButtonsBar(
      this.isSummarizing,
      this.speechEnabled,
      this.transcribedText,
      this.gptResponse,
      this.speechToText,
      this.clearGPTResponse,
      this.chatComplete,
      this.speak,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        showSummarizeButton(),
        showClearButton(),
      ],
    );
  }

  FloatingActionButton showClearButton() {
    return FloatingActionButton(
      onPressed: () => clearGPTResponse(),
      backgroundColor:
          transcribedText.isNotEmpty ? Colors.blue : Colors.grey,
      tooltip: 'Clear',
      child: const Icon(Icons.clear),
    );
  }

  Widget showSummarizeButton() {
    return isSummarizing
        ? const CircularProgressIndicator()
        : FloatingActionButton(
            onPressed: () async {
              chatComplete(transcribedText);

              if (speechEnabled) {
                speak(gptResponse);
              }
            },
            backgroundColor:
                (transcribedText.isNotEmpty && speechToText.isNotListening)
                    ? Colors.blue
                    : Colors.grey,
            tooltip: "Summarize",
            child: Icon(transcribedText.isNotEmpty
                ? Icons.summarize
                : Icons.comments_disabled),
          );
  }
}
