import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> order =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order['orderId']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Customer: ${order['customerName']}'),
            Text('Email: ${order['customerEmail']}'),
            Text('Phone: ${order['customerPhone']}'),
            const Divider(height: 20),
            const Text('Items:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List<Widget>.from((order['items'] as List).map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('${item['quantity']}x ${item['itemName']} - \$${item['subtotal']}'),
                ))),
            const Divider(height: 20),
            Text('Total: \$${order['totalOrderPrice']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Status: ${order['status']}'),
          ],
        ),
      ),
    );
  }
}
