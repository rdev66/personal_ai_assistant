import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_continuous_none/provider/google_speech_provider.dart';
import 'package:speech_continuous_none/util/search_youtube.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../provider/functions/google_provider_functions.dart';
import '../util/debouncer.dart';
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
  Widget build(BuildContext context) {

    final transcribedText =
        Provider.of<GoogleSpeechProvider>(context, listen: true).googleSpeechTranscript;

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
                        debugPrint('search');
                        searchYoutubeVideos(query).then((results) => setState(
                              () => videosList.addAll(results),
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
                                                          // Close the dialog
                                                          Navigator.of(context)
                                                              .pop();

                                                          // Remove the box
                                                          setState(() {
                                                            videosList.clear();
                                                          });

                                                          // Process the video
                                                          processYoutubeContent(
                                                              context,
                                                              selectedVideo);
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
                    height: 100,
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
    debugPrint("updateVids: ${videosList.toList()}");
  }
}
