// home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final List<dynamic> vendors = args?['menus'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Menus')),
      body: vendors.isEmpty
          ? const Center(child: Text('No menu items available.'))
          : ListView.builder(
              itemCount: vendors.length,
              itemBuilder: (context, vendorIndex) {
                final vendor = vendors[vendorIndex];
                final vendorName = vendor['vendorName'] ?? 'Unknown Vendor';
                final menus = vendor['menus'] as List<dynamic>? ?? [];

                return ExpansionTile(
                  title: Text(vendorName),
                  children: menus.map<Widget>((menu) {
                    final menuName = menu['menuName'] ?? 'Unnamed Menu';

                    return ListTile(
                      title: Text(menuName),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/menuDetails',
                          arguments: {
                            'vendorName': vendorName,
                            'menu': menu,
                          },
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
