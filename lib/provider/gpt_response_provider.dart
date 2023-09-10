import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GptResponseProvider extends ChangeNotifier {
  //const gptPrompt = 'TLDR: ';
  final gptPromptBullet =
      'Using extractive summarization, condense this business report into key bullet points: ';

  var gptSummary = "";

  final openAI = OpenAI.instance.build(
      enableLog: true,
      token: "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",
      baseOption: HttpSetup(
        sendTimeout: const Duration(seconds: 50),
        receiveTimeout: const Duration(seconds: 50),
        connectTimeout: const Duration(seconds: 50),
      ));

  void chatComplete(String textToSummarize) async {
    if (gptSummary.isNotEmpty) {
      debugPrint("Already summarized");
      return;
    }

    final request = ChatCompleteText(messages: [
      Messages(role: Role.user, content: '$gptPromptBullet $textToSummarize'),
    ], maxToken: 200, model: Gpt4ChatModel());

    final response =
        await openAI.onChatCompletion(request: request).catchError((err) {
      if (err is OpenAIAuthError) {
        debugPrint('OpenAIAuthError error ${err.data?.error.toMap()}');
      }

      if (err is OpenAIRateLimitError) {
        debugPrint('OpenAIRateLimitError error ${err.data?.error.toMap()}');
      }
      if (err is OpenAIServerError) {
        debugPrint('OpenAIServerError error $err');
        debugPrint('OpenAIServerError error ${err.data?.error.toMap()}');
      }
      return null;
    });

    if (response == null || response.choices.isEmpty) {
      debugPrint("No response");
      return;
    }

    gptSummary = response.choices.first.message!.content;

    //
    notifyListeners();
  }

  void clearGPTResponse() {
    gptSummary = '';
    //
    notifyListeners();
  }
}
