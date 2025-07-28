import 'package:flutter/material.dart';

class DinorTVScreen extends StatelessWidget {
  const DinorTVScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        child: Text(
          'Dinor TV (à implémenter)',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
      ),
    );
  }
}