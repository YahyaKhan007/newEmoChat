// ignore_for_file: unnecessary_null_comparison

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/provider/modeprovider.dart';

class EmotionRecognitionPage extends StatefulWidget {
  @override
  _EmotionRecognitionPageState createState() => _EmotionRecognitionPageState();
}

class _EmotionRecognitionPageState extends State<EmotionRecognitionPage> {
  String? responseCode = '';
  @override
  Widget build(BuildContext context) {
    ModeProvider modeProvider =
        Provider.of<ModeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Emotion Recognition"),
        actions: [
          IconButton(
              onPressed: () {
                modeProvider.updateBase64Image(
                    "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");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Updated"),
                  duration: Duration(seconds: 3),
                ));
              },
              icon: Icon(Icons.update))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                try {
                  Dio dio = Dio();
                  final response = await dio.get(
                      "http://146.190.212.199:5005/detect",
                      data: {'image': '${modeProvider.base64Image}'});
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("API HIT"),
                      duration: Duration(seconds: 3),
                    ));

                    setState(() {
                      Map<String, dynamic> responseData = response.data;
                      responseCode = responseData['emotion'];
                    });
                  }
                } catch (e) {}
              },
              child: Text("Make a Request"),
            ),
            SizedBox(height: 20.0),
            Text(
              "Response --- > $responseCode",
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 30.0),
            Container(
              height: 200,
              width: 200,
              child: modeProvider.base64Image != null
                  ? Text("${modeProvider.base64Image}")
                  : Text("Nothing yet"),
            )
          ],
        ),
      ),
    );
  }
}
