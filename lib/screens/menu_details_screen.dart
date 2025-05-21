// menu_details.dart
import 'package:flutter/material.dart';

class MenuDetailsScreen extends StatelessWidget {
  const MenuDetailsScreen({super.key});

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
                      // Placeholder logic for adding to cart
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$itemName added to cart')),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart, color: Colors.deepOrange),
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
