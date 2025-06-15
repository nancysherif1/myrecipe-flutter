import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  // ignore: use_super_parameters
  const CheckoutScreen({Key? key, required this.orderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = orderData['items'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Order ID: ${orderData['order_id']}"),
            Text("Customer: ${orderData['customer_name']}"),
            Text("Order Date: ${orderData['order_date']}"),
            Text("Status: ${orderData['status']}"),
            Text("Payment Method: ${orderData['payment_method']}"),
            
            // Display comment if it exists
            if (orderData['comment'] != null && orderData['comment'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Order Comments:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderData['comment'].toString(),
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...items.map((item) => ListTile(
              title: Text(item['item_name']),
              subtitle: Text(
                "Qty: ${item['quantity']} • LE${item['price']} each",
              ),
              trailing: Text("Subtotal: LE${item['subtotal']}"),
            )),
            const Divider(),
            Text(
              "Total Amount: LE${orderData['total_amount'].toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("Item Count: ${orderData['item_count']}"),
          ],
        ),
      ),
    );
  }
}