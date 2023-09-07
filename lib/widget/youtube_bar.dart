import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_continuous_none/util/search_youtube.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
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
    searchYoutubeVideos("Taylor Swift").then((value) => setState(
          () {
            videosList.addAll(value);
          },
        ));
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
                'Transcript from Youtube:',
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
                        searchYoutubeVideos(query).then((value) => setState(
                              () {
                                videosList.addAll(value);
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
              SizedBox(
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
                                  title: Text(
                                    videosList[index].title,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  subtitle: Text(
                                    videosList[index].author,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }))),
              SizedBox(
                height: 20,
                child: ListView(children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Youtube Transcript will be displayed here',
                      style:
                          TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                    ),
                  )
                ]),
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
}
