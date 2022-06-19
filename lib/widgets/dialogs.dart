import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_search/models/textmodel.dart';

class CustomDialog extends StatefulWidget {
  const CustomDialog({
    required this.text,
    required this.resultText,
    Key? key,
  }) : super(key: key);
  final String text;
  final String resultText;

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    String text = context.watch<TextModel>().text;
    return StatefulBuilder(
      builder: ((context, setState) {
        return AlertDialog(
          scrollable: true,
          actions: [
            ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
          title: const Center(child: Text("Google")),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AvatarGlow(
                endRadius: 75,
                glowColor: Theme.of(context).primaryColor,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 5),
                      ),
                    ],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(widget.text),
              Text(text),
              FutureBuilder(
                  future: Future.delayed(Duration(seconds: 3)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Text(
                        'Please speak quickly',
                        style: TextStyle(color: Colors.red),
                      );
                    }
                    return const Text('');
                  }),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        );
      }),
    );
  }
}
