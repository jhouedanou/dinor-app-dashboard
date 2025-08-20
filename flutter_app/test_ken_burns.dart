import 'package:flutter/material.dart';
import 'lib/services/ken_burns_slideshow_service.dart';

void main() {
  runApp(TestKenBurnsApp());
}

class TestKenBurnsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: KenBurnsSlideshowWidget(
          totalDuration: Duration(seconds: 20),
        ),
      ),
    );
  }
}