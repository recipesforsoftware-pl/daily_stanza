import 'package:flutter/material.dart';

class TodayView extends StatelessWidget {
  const TodayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Stanza')),
      body: const Center(child: Text('Today — Phase 2')),
    );
  }
}
