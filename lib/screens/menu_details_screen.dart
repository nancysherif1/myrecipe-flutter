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

                return ListTile(
                  title: Text(itemName),
                  subtitle: Text('$description\n\$${price.toStringAsFixed(2)}'),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}
