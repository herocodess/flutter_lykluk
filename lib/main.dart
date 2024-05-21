import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_job_test/firebase_options.dart';
import 'package:flutter_job_test/src/screens/video_taker_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FlutterJobTest());
}

/// CameraApp is the Main Application.
class FlutterJobTest extends StatefulWidget {
  /// Default Constructor
  const FlutterJobTest({super.key});

  @override
  State<FlutterJobTest> createState() => _FlutterJobTestState();
}

class _FlutterJobTestState extends State<FlutterJobTest> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: VideoTakerScreen(),
    );
  }
}
