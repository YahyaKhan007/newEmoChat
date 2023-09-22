import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewPage extends StatefulWidget {
  final String text;
  const NewPage({super.key, required this.text});

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  copyToClipboard(context, widget.text);
                },
                icon: Icon(Icons.copy_all))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [SelectableText(widget.text)],
          ),
        ));
  }

  void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Text copied to clipboard'),
      ),
    );
  }
}
