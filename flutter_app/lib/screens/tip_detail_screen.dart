import 'package:flutter/material.dart';

class TipDetailScreen extends StatelessWidget {
  final String id;
  
  const TipDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Text(
          'Astuce $id (à implémenter)',
          style: const TextStyle(
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