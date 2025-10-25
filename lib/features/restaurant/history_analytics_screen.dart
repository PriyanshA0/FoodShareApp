import 'package:flutter/material.dart';

class HistoryAnalyticsScreen extends StatelessWidget {
  const HistoryAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History & Analytics')),
      body: const Center(child: Text('Detailed history and analytics charts.')),
    );
  }
}
