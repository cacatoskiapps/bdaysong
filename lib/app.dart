import 'package:flutter/material.dart';
import 'features/birthday_song/birthday_song_page.dart';

class HappyBdaySongApp extends StatelessWidget {
  const HappyBdaySongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HappyBday Song',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const BirthdaySongPage(),
    );
  }
}
