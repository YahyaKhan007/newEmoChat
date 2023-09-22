import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String? mostFrequent = null;
  String? secondFrequent = null;
  final dio = Dio();
  List<String> emotions = [];
  late CameraController _controller;
  Timer? _timer;
  File? capturedImage;
  String? _emotion = null;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _startCapturing();
      } else {
        _stopCapturing();
      }
    });
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCapturing() {
    if (!_controller.value.isInitialized) {
      _initializeCamera();
    }
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_controller.value.isInitialized) {
        _captureImage();
      }
    });
  }

  void _stopCapturing() {
    _timer?.cancel();
    print("{$emotions}");
    setState(() {
      capturedImage = null;
    });
    // _controller.dispose();
  }

  Future<void> _captureImage() async {
    try {
      final XFile file = await _controller.takePicture();

      Uint8List? imageBytes = await File(file.path).readAsBytes();
      String capturedImageBase64 = base64.encode(imageBytes);
      print(capturedImageBase64);
      fetchData(base64String: capturedImageBase64);

      setState(() {
        capturedImage = File(file.path);
      });
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  // !     REQUEST THE SERVER

  void fetchData({required String base64String}) async {
    try {
      print("it came here");
      final response = await dio.get("http://167.172.133.166:5000/detect",
          queryParameters: {'image': '${base64String}'});

      if (response.statusCode == 200) {
        print("aslo came ....................");
        Map<String, dynamic>? responseData = null;
        responseData = response.data;
        if (responseData != null) {
          setState(() {
            // _emotion = responseData!["emotion"];
            emotions.add(responseData!["emotion"]);
          });
        }

        // HTTP status code 200 indicates success
        log("API Success");
        print("Request successful");
        print("Response data: ${responseData}");
      } else {
        log("API Not Hit");

        // Handle different HTTP status codes here
        print("Request failed with status code ${response.statusCode}");
        print("Response data: ${response.data}");
      }
    } catch (e) {
      // Handle exceptions, such as network errors or timeouts
      print("Problem occurred: $e");
    }
  }

  void findMode() {
    Map<String, int> frequencyMap = {};

    for (String str in emotions) {
      if (frequencyMap.containsKey(str)) {
        frequencyMap[str] =
            frequencyMap[str]! + 1; // Ensure the entry exists and increment it.
      } else {
        frequencyMap[str] = 1;
      }
    }

    var sortedEntries = frequencyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    setState(() {
      mostFrequent = sortedEntries.isNotEmpty ? sortedEntries.first.key : "";
      secondFrequent = sortedEntries.length > 1 ? sortedEntries[1].key : "";
      if (mostFrequent != "neutral") {
        _emotion = mostFrequent;
      } else if (secondFrequent != "neutral") {
        _emotion = secondFrequent;
      } else {
        _emotion = mostFrequent;
      }
    });

    print(mostFrequent);
    print(secondFrequent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Front Camera Capture'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  findMode();
                },
                child: Text("Mode Finder"),
              ),
              TextButton(
                onPressed: () {
                  emotions.add("Happy");
                  print(emotions);
                },
                child: Text("Add"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Emotion of the Picture is "),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Text("$_emotion"),
                  )
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                ),
                child: capturedImage != null
                    ? Image.file(
                        capturedImage!,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Text('No Image Captured'),
                      ),
              ),
              SizedBox(height: 20),
              TextField(
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Type something...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
