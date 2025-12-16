import 'package:flutter/material.dart';

class LogicDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const LogicDetailScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
