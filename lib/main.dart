import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_search/Screens/homepage.dart';
import 'package:voice_search/models/textmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TextModel('', false, false),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Voice Search',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}
