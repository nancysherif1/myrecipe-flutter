import 'package:flutter/material.dart';

class RecentOrdersScreen extends StatelessWidget {
  const RecentOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recent Orders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A0D1F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'No recent orders yet.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
