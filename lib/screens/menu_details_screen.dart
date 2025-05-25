import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MenuDetailsScreen extends StatelessWidget {
  const MenuDetailsScreen({super.key});

 Future<void> addToCart(int itemId, int quantity, BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (!context.mounted) return; // <--- ADD THIS LINE

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You must be logged in to add items to the cart')),
    );
    return;
  }

  final response = await http.post(
    Uri.parse('http://127.0.0.1:8000/api/cart/'),
    headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'item_id': itemId,
      'quantity': quantity,
    }),
  );

  if (!context.mounted) return; // <--- ADD THIS LINE AGAIN

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
        leading: BackButton(),
      ),
      body: items.isEmpty
          ? const Center(child: Text('No items in this menu.'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final itemName = item['itemName'] ?? 'Unnamed Item';
                final price = item['price'] ?? 0.0;
                final description = item['description'] ?? '';
                final itemId = item['itemId']; // Make sure 'id' exists in the item

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
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${price.toStringAsFixed(2)}',
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
      addToCart(itemId, 1, context); // default quantity = 1
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item ID is missing')),
      );
    }
  },                          icon: const Icon(Icons.add_shopping_cart, color: Colors.deepOrange),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
