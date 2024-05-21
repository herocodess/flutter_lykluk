import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_test/src/screens/video_list_screen.dart';
import 'package:path_provider/path_provider.dart';

class VideoTakerScreen extends StatefulWidget {
  const VideoTakerScreen({super.key});

  @override
  State<VideoTakerScreen> createState() => _VideoTakerScreenState();
}

class _VideoTakerScreenState extends State<VideoTakerScreen> {
  CameraController? cameraController;
  late List<CameraDescription> _cameras;
  String videoPath = '';

  @override
  void initState() {
    super.initState();

    initializeCamera();
  }

  void initializeCamera() async {
    _cameras = await availableCameras();

    // final front = _cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
    cameraController = CameraController(_cameras.first, ResolutionPreset.max);
    cameraController?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Test"),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) {
              return const VideoListPage();
            },
          ),
        );
      }),
      body: Column(
        children: [
          CameraPreview(cameraController!),
          Row(
            children: [
              ElevatedButton(
                onPressed: startRecording,
                child: const Text('Start Recording'),
              ),
              ElevatedButton(
                onPressed: stopRecording,
                child: const Text('Stop Recording'),
              ),
            ],
          ),
          if (videoPath.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                uploadVideo(File(videoPath));
              },
              child: const Text('Upload Video'),
            ),
        ],
      ),
    );
  }

  Future<void> startRecording() async {
    await cameraController?.prepareForVideoRecording();
    await cameraController!.startVideoRecording();
  }

  Future<void> stopRecording() async {
    final file = await cameraController!.stopVideoRecording();
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    setState(() {
      log("\n");
      log("/////////");
      log("video file path => ${file.path}");
      log("size => ${file.length()}");
      log("/////////");
      log("\n");
      videoPath = file.path;
    });
  }

  Future<void> uploadVideo(File video) async {
    try {
      File videoFile =
          File(videoPath); // videoPath is the path to your video file
      log('Video file path: ${videoFile.path}');
      log('File exists: ${videoFile.existsSync()}');

      // Create a reference to the Firebase Storage bucket
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref =
          storage.ref().child('videos/${video.path.split('/').last}');

      // Upload the video file
      UploadTask uploadTask = ref.putFile(video);

      // Monitor the upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        log('Task state: ${snapshot.state}');
        log('Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
      });

      // Complete the upload task and get the download URL
      await uploadTask.whenComplete(() async {
        String downloadURL = await ref.getDownloadURL();
        log('Download URL: $downloadURL');
      });
    } catch (e) {
      log('Error uploading video: $e');
    }
  }
}
