import 'package:flutter/material.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:speech_continuous_none/util/search_youtube.dart';
import 'toggle_bar.dart';

class YoutubeBar extends StatelessWidget {
  const YoutubeBar(this.toggleSelected, this.selected, {super.key});

  final Function toggleSelected;
  final List<bool> selected;

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
            ToggleBar(toggleSelected, selected),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                    height: 89,
                    child: (SearchableList<String>(
                      initialList: const [],
                      filter: null,
                      builder: (initialIndex, actualIndex) {
                        return Container();
                      },
                      asyncListCallback: () async {
                        await Future.delayed(
                          const Duration(
                            milliseconds: 1000,
                          ),
                        );
                        return searchYoutube("Guitar");
                      },
                      asyncListFilter: (q, list) {
                        return list
                            .where((element) => element.contains(q))
                            .toList();
                      },
                      loadingWidget: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 20,
                          ),
                          Text('Loading results...')
                        ],
                      ),
                      errorWidget: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text('Error while fetching results')
                        ],
                      ),
                      inputDecoration: InputDecoration(
                        labelText: "Search Youtube",
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ))),
                SizedBox(
                  height: 175,
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
        ),
      ],
    );
  }
}
