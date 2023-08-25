// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:simplechat/main.dart';
// import 'package:tflite/tflite.dart';

// class EmotionDetector extends StatefulWidget {
//   const EmotionDetector({super.key});

//   @override
//   State<EmotionDetector> createState() => _EmotionDetectorState();
// }

// class _EmotionDetectorState extends State<EmotionDetector> {
//   CameraImage? cameraImage;
//   late CameraController cameraController;
//   String? output;

//   late final CameraDescription camera;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     loadCamera();
//     loadModel();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final frontCamera = cameras.firstWhere(
//       (camera) => camera.lensDirection == CameraLensDirection.front,
//       orElse: () => cameras.first,
//     );
//     cameraController = CameraController(
//       frontCamera,
//       ResolutionPreset.low,
//       enableAudio: false,
//     );
//     await cameraController!.initialize();
//   }

// //?  -_-__--__-_-_--------_-____
//   // ! Load Camera Function
// //^  -_-__--__-_-_--------_-____

//   loadCamera() async {
//     cameraController = CameraController(
//       cameras![0],
//       ResolutionPreset.medium,
//     );

//     await cameraController.initialize();
//     if (!mounted) {
//       return;
//     } else {
//       cameraController.startImageStream((ImageStream) {
//         setState(() {
//           cameraImage = ImageStream;
//           runModel();
//         });
//       });
//     }
//   }

//   //?  -_-__--__-_-_--------_-____
//   // ! Run Model Function
// //^  -_-__--__-_-_--------_-____
//   runModel() async {
//     if (cameraImage != null) {
//       var predictions = await Tflite.runModelOnFrame(
//         bytesList: cameraImage!.planes.map((plane) {
//           return plane.bytes;
//         }).toList(),
//         imageHeight: cameraImage!.height,
//         imageWidth: cameraImage!.width,
//         imageMean: 127.5,
//         imageStd: 127.5,
//         rotation: 90,
//         threshold: 0.1,
//         numResults: 2,
//         asynch: true,
//       );
//       predictions!.forEach((element) {
//         setState(() {
//           output = element['label'];
//         });
//       });
//     }
//   }
// //?^ -_-__--__-_-_--------_-____

//   //?  -_-__--__-_-_--------_-____
//   // ! Load Model Function

//   loadModel() async {
//     await Tflite.loadModel(
//         model: 'assets/machineLearningModel/emotionDetector.tflite',
//         labels: 'assets/machineLearningModel/labels.txt');
//   }
// //^  -_-__--__-_-_--------_-____

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Emotion Detection Live"),
//       ),
//       body: Column(children: [
//         Text(
//           "${output}",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         Padding(
//           padding: EdgeInsets.all(20),
//           child: Container(
//             height: size.height,
//             width: size.width,
//             child: !cameraController!.value.isInitialized
//                 ? Container()
//                 : Container(
//                     height: size.height * 0.6,
//                     child: CameraPreview(cameraController!),
//                   ),
//           ),
//         ),
//       ]),
//     );
//   }
// }
