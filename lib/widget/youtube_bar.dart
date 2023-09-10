import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/generated/google/cloud/speech/v1/cloud_speech.pb.dart';
import 'package:googleapis/speech/v1.dart' as speech;
import 'package:googleapis_auth/auth_io.dart';
import 'package:speech_continuous_none/util/search_youtube.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;
import '../util/debouncer.dart';
import '../util/download_from_youtube.dart';
import '../util/upload_to_cloud.dart';
import 'toggle_bar.dart';

class YoutubeBar extends StatefulWidget {
  const YoutubeBar(this.toggleSelected, this.selected, {super.key});

  final Function toggleSelected;
  final List<bool> selected;

  @override
  State<YoutubeBar> createState() => _YoutubeBarState();
}

class _YoutubeBarState extends State<YoutubeBar> {
  final _debouncer = Debouncer();
  List<Video> videosList = [];
  List<Video> vlist = [];
  late Video selectedVideo;
  String transcribedText = '';
  late final speech.SpeechApi speechApi;

  String query = '';

  //API call for All Subject List
  //  String url = 'https://type.fit/api/quotes';

  /*
  * Video._internal(id: Dh-k6EcwPmI, 
  title: Query | A Short film by Sophie Kargman featuring Armie Hammer, 
  author: MAGNETFILM, channelId: UCA4vCk59oUmlBvyvXNiXQ7w, 
  uploadDate: 2022-09-07 15:24:07.887633, 
  uploadDateRaw: 1 year ago, 
  publishDate: null, 
  description: Subtitles available in English, Italian, Portuguese Over the course of a day, Jay and Alex, roommates and best friends, spend their ..., 
  duration: 0:09:08.000000, 
  thumbnails: ThumbnailSet(videoId: Dh-k6EcwPmI), 
  keywords: [], 
  engagement: Engagement(viewCount: 184552, likeCount: null, dislikeCount: null), 
  isLive: false, 
  watchPage: null)
  */

  @override
  void initState() {
    super.initState();
    initSpeechApi();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Transcribe from Youtube:',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            ToggleBar(widget.toggleSelected, widget.selected),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //Search Bar to List of typed Subject
              Container(
                padding: const EdgeInsets.all(5),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        if (kDebugMode) {
                          print('search');
                        }
                        searchYoutubeVideos(query).then((results) => setState(
                              () {
                                //TODO Sort results ??
                                //results
                                //  .sort((a,b) => a.uploadDate.difference(b.uploadDate!).inMilliseconds);

                                videosList.addAll(results);
                              },
                            ));
                      },
                      child: const Icon(Icons.search),
                    ),
                    contentPadding: const EdgeInsets.all(15.0),
                    hintText: 'Search Youtube Videos',
                  ),
                  onChanged: (updatedString) {
                    _debouncer.run(() {
                      setState(() {
                        query = updatedString;
                        videosList = vlist
                            .where(
                              (u) => (u.title.toLowerCase().contains(
                                    updatedString.toLowerCase(),
                                  )),
                            )
                            .toList();
                      });
                    });
                  },
                ),
              ),
              videosList.isEmpty
                  ? Container()
                  : SizedBox(
                      height: 275,
                      child: (ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.all(5),
                          itemCount: videosList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ListTile(
                                      onTap: () {
                                        if (kDebugMode) {
                                          print(
                                              'Youtube Video: ${videosList[index].title}');
                                        }
                                        selectedVideo = videosList[index];

                                        showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                                  title: const Text(
                                                    'Please Confirm transcription',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  content: Text(
                                                      'Are you sure to transcribe: ${selectedVideo.title} ?'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          // Close the dialog
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          'No',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                    // The "Yes" button
                                                    TextButton(
                                                        onPressed: () {
                                                          // Remove the box
                                                          setState(() {
                                                            videosList.clear();
                                                            transcribedText ='';
                                                          });

                                                          // Process the video
                                                          processYoutubeContent(
                                                              selectedVideo,
                                                              context);
                                                          // Close the dialog
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          'Yes',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                  ],
                                                ));
                                      },
                                      title: Text(
                                        videosList[index].title,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      subtitle: Text(
                                        '${videosList[index].duration?.inMinutes} minutes',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }))),
              Column(
                children: [
                  SizedBox(
                    height: 20,
                    child: ListView(children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: const Text(
                          'Youtube Transcript will be displayed here',
                          style: TextStyle(
                              fontSize: 18, fontStyle: FontStyle.italic),
                        ),
                      )
                    ]),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView(children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          transcribedText.isNotEmpty
                              ? transcribedText
                              : 'Waiting for transcription..',
                          style: const TextStyle(
                              fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                      )
                    ]),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  void updateVids(String query) async {
    var newVids = await searchYoutubeVideos(query);
    videosList.clear();
    videosList.addAll(newVids);
    if (kDebugMode) {
      print("updateVids: ${videosList.toList()}");
    }
  }

  Future<String?> sendForRecognition(String storageUrl, File file) async {
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

  Future<String> fetchTranscribeOperationResultsApi(
      String operationName) async {
    var conversation = "";

    print("fetchTranscribeOperationResultsApi: $operationName");

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

  void processYoutubeContent(Video selectedVideo, BuildContext context) async {
    var saveFile = await downloadFromYoutube(selectedVideo);
    debugPrint("saveFile: $saveFile");
    var storageUrl = await uploadToCloud(selectedVideo, context);
    debugPrint("storageUrl: $storageUrl");

    final opName = await sendForRecognition(storageUrl, saveFile);

    if (opName == null) {
      debugPrint("No operation generated for transcript");
      return;
    }

    final transcript = await fetchTranscribeOperationResultsApi(opName);

    setState(() {
      transcribedText = transcript;
    });
  }

  Future<void> initSpeechApi() async {
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
        await rootBundle.loadString('assets/rdev_service_account.json'));

    final httpClient = await clientViaServiceAccount(
        serviceAccountCredentials, [speech.SpeechApi.cloudPlatformScope]);

    speechApi = speech.SpeechApi(httpClient);
  }
}
