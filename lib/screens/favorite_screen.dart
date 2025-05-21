import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Items',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A0D1F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'No favorite items yet.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
