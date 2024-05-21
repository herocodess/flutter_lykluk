// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoListPage extends StatefulWidget {
  const VideoListPage({super.key});

  @override
  _VideoListPageState createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  List<String> videoUrls = [];

  @override
  void initState() {
    super.initState();
    fetchVideoUrls();
  }

  Future<void> fetchVideoUrls() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    ListResult result = await storage.ref('videos').listAll();
    List<String> urls = await Future.wait(
        result.items.map((ref) => ref.getDownloadURL()).toList());

    setState(() {
      videoUrls = urls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video List'),
      ),
      body: videoUrls.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: videoUrls.length,
              itemBuilder: (context, index) {
                return VideoPlayerItem(videoUrl: videoUrls[index]);
              },
            ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerItem({super.key, required this.videoUrl});

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _videoPlayerController.value.isInitialized
        ? AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
