import 'package:flutter/material.dart';
import 'lib/services/ken_burns_slideshow_service.dart';

void main() {
  runApp(TestKenBurnsApp());
}

class TestKenBurnsApp extends StatelessWidget {
  const TestKenBurnsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: KenBurnsSlideshowWidget(
          totalDuration: Duration(seconds: 20),
        ),
      ),
    );
  }
}