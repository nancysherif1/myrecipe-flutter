import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MenuDetailsScreen extends StatelessWidget {
  const MenuDetailsScreen({super.key});

  Future<void> addToCart(int itemId, int quantity, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (!context.mounted) return;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add items to the cart')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/cart/'),
      // Uri.parse('http://172.20.10.3:8000/api/cart/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'item_id': itemId,
        'quantity': quantity,
      }),
    );

    if (!context.mounted) return;

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added to cart')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item: ${response.body}')),
      );
    }
  }

  Future<String> getImagePathForVendor(BuildContext context, String vendorName) async {
    final assetPath = 'assets/images/$vendorName.jpg';
    try {
      await DefaultAssetBundle.of(context).load(assetPath);
      return assetPath;
    } catch (_) {
      return 'assets/images/menu3.jpg'; // fallback image
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String vendorName = args?['vendorName'] ?? 'Unknown Vendor';
    final Map<String, dynamic> menu = args?['menu'] ?? {};
    final String menuName = menu['menuName'] ?? 'Unnamed Menu';
    final List<dynamic> items = menu['items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('$menuName - $vendorName'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // Display the vendor image at the top
          FutureBuilder<String>(
            future: getImagePathForVendor(context, vendorName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final imagePath = snapshot.data ?? 'assets/images/menu3.jpg';
              return Image.asset(
                imagePath,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              );
            },
          ),
          const SizedBox(height: 8),

          // Show items
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No items in this menu.'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final itemName = item['itemName'] ?? 'Unnamed Item';
                      final price = item['price'] ?? 0.0;
                      final description = item['description'] ?? '';
                      final itemId = item['itemId'];

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'LE${price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (itemId != null) {
                                    addToCart(itemId, 1, context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Item ID is missing')),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.add_shopping_cart, color: Colors.deepOrange),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
