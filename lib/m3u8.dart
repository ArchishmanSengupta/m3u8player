import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:video_player/video_player.dart';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

List<String> qualityOptions = [];
List<String> urls = [];

int selectedQualityIndex = 0;
Map<String, String> resolutionToUrl = {};
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoPlayer(
        videoUrl:
            'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
      ),
    );
  }
}

class VideoPlayer extends StatefulWidget {
  final String videoUrl;

  VideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  @override
  void initState() {
    super.initState();
    _getVideoQuality();
  }

  void _getVideoQuality() async {
    var url = Uri.parse('https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final body = res.body;
      print("body --> $body");
      final lines = body.split("#");
      for (String line in lines) {
        if (line.startsWith("EXT-X-STREAM-INF")) {
          List<String> temp = line.split(",");
          if (temp.length < 4) {
            continue;
          }
          final quality = temp[3];

          String name = line.split("\n")[1];
          resolutionToUrl[quality] =
              "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/$name";
          urls.add(
              "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/$name");
          qualityOptions.add(quality);
        }
      }
      setState(() {});
    }
  }

  void _selectQuality(int index) {
    setState(() {
      selectedQualityIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: VideoPlayerScreen(
              videoUrl: widget.videoUrl,
              selectedQualityIndex: selectedQualityIndex,
            ),
          ),
          Container(
            color: Colors.grey[300],
            child: QualitySelector(
              qualityOptions: qualityOptions,
              selectedQualityIndex: selectedQualityIndex,
              onSelect: (index) {
                // print(resolutionToUrl[qualityOptions[selectedQualityIndex]]!);
                _selectQuality(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerScreen extends StatelessWidget {
  final String videoUrl;
  final int selectedQualityIndex;

  VideoPlayerScreen(
      {required this.videoUrl, required this.selectedQualityIndex});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Chewie(
        controller: ChewieController(
          videoPlayerController: VideoPlayerController.network(
              resolutionToUrl[qualityOptions[selectedQualityIndex]]!),
          aspectRatio: 16 / 9,
          autoPlay: true,
          looping: true,
        ),
      ),
    );
  }
}

class QualitySelector extends StatelessWidget {
  final List<String> qualityOptions;
  final int selectedQualityIndex;
  final Function onSelect;

  QualitySelector(
      {required this.qualityOptions,
      required this.selectedQualityIndex,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Text("Quality:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8.0),
          DropdownButton(
            icon: Icon(Icons.arrow_drop_down_circle_sharp),
            items: qualityOptions
                .asMap()
                .map((index, quality) => MapEntry(
                      index,
                      DropdownMenuItem(
                        child: Text(quality),
                        value: index,
                      ),
                    ))
                .values
                .toList(),
            value: selectedQualityIndex,
            onChanged: (index) {
              onSelect(index);
            },
          ),
        ],
      ),
    );
  }
}