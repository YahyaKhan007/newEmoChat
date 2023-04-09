import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simplechat/colors/colors.dart';
import 'package:simplechat/widgets/drawer_icon.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final cameras = await availableCameras();
//   // final firstCamera = cameras.first;
//   final frontCamera = cameras.firstWhere(
//     (camera) => camera.lensDirection == CameraLensDirection.front,
//   );

//   runApp(MyApp(frontCamera));
// }

// class MyApp extends StatelessWidget {
//   final CameraDescription camera;

//   const MyApp(this.camera);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Camera Demo',
//       home: ChatPage(),
//     );
//   }
// }

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final CameraDescription camera;
  late File _image;

  @override
  void initState() {
    super.initState();
    _image = File('assets/images/dummy_image.png');
    _initializeCamera();
  }

  late CameraController _cameraController;

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.low,
      enableAudio: false,
    );
    await _cameraController.initialize();
    _startTimer();
  }

  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_textEditingController.text.isNotEmpty) {
        _captureImage();
      }
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  Future<void> _captureImage() async {
    try {
      final imageBytes = await _cameraController.takePicture();
      setState(() {
        _image = File(imageBytes.path);
      });
      print('Image captured');
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  final _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    _stopTimer();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: drawerIcon(context),
        backgroundColor: AppColors.backgroudColor,
        title: Text(
          'Taking photo demo for the model',
          style: TextStyle(
              fontSize: 11.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_image != null)
                    Container(
                        height: 200, width: 200, child: Image.file(_image)),
                ],
              ),
            ),
          ),
          TextField(
            controller: _textEditingController,
            onChanged: (value) {
              if (value.isNotEmpty) {
                _startTimer();
              } else {
                _stopTimer();
              }
            },
            onSubmitted: (value) {
              _stopTimer();
              _textEditingController.clear();
              print('Message sent');
            },
            decoration: InputDecoration(
              hintText: 'Type your message here...',
            ),
          ),
        ],
      ),
    );
  }
}
