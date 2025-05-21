import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/cart/'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        cartItems = data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void removeItem(int itemId) {
    setState(() {
      cartItems.removeWhere((item) => item['item']['id'] == itemId);
    });
    // Optionally send delete request to API here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty.'))
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index]['item'];
                    return ListTile(
                      title: Text(item['itemName']),
                      subtitle: Text('${item['vendorName']} • \$${item['price'].toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => removeItem(item['id']),
                      ),
                    );
                  },
                ),
    );
  }
}
