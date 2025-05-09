import 'package:flutter/material.dart';

class SignupChoiceScreen extends StatelessWidget {
  const SignupChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CHOOSE')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('CHOOSE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOptionCard(context, 'Chief', 'assets/images/chief.jpg', '/registerChief'),
              const SizedBox(width: 20),
              _buildOptionCard(context, 'Client', 'assets/images/client.jpg', '/registerClient'),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String label, String imagePath, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(imagePath),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
