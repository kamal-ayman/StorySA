// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:screenshot/screenshot.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   late String _recognizedText;
//   final ScreenshotController screenshotController = ScreenshotController();
//
//   @override
//   void initState() {
//     super.initState();
//     _recognizedText = '';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('UDictionary Scan Example'),
//       ),
//       body: Screenshot(
//         controller: screenshotController,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Recognized Text:',
//                 style: TextStyle(fontSize: 18),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 _recognizedText,
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await _captureScreen();
//         },
//         child: Icon(Icons.camera_alt),
//       ),
//     );
//   }
//
//   Future<void> _captureScreen() async {
//     final Uint8List? screenCapture = await screenshotController.capture();
//     if (screenCapture != null) {
//       await _processImageBytes(screenCapture);
//     }
//   }
//
//   Future<void> _processImageBytes(Uint8List imageBytes) async {
//     final InputImage visionImage = InputImage.fromBytes(bytes: imageBytes, metadata: InputImageMetadata());
//     final TextRecognizer textRecognizer = Vision.instance.textRecognizer();
//
//     try {
//       final Vision visionText = await textRecognizer.processImage(visionImage);
//
//       // Get the recognized text
//       final String recognizedText = visionText.text;
//
//       setState(() {
//         _recognizedText = recognizedText;
//       });
//     } catch (e) {
//       print('Error processing image: $e');
//     } finally {
//       textRecognizer.close();
//     }
//   }
// }
