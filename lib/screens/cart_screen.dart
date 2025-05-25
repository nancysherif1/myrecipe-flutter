import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      developer.log('Token not found. User might not be logged in.', name: 'CartScreen');
      setState(() => isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/cart/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        cartItems = data['items'] ?? [];
        isLoading = false;
      });
    } else {
      developer.log('Failed to fetch cart', name: 'CartScreen', error: response.body);
      setState(() => isLoading = false);
    }
  }

Future<void> removeItem(int itemId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    developer.log('Token not found. Cannot remove item.', name: 'CartScreen');
    return;
  }

  final response = await http.delete(
    Uri.parse('http://127.0.0.1:8000/api/cart/item/$itemId/'),
    headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    },
  );

  if (!mounted) return; // ✅ Check if the widget is still in the widget tree

  if (response.statusCode == 204 || response.statusCode == 200) {
    setState(() {
      cartItems.removeWhere((item) => item['item'] == itemId);
    });
  } else {
    developer.log('Failed to delete item $itemId', name: 'CartScreen', error: response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to remove item. Please try again.')),
    );
  }
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
                    final item = cartItems[index];
                    return ListTile(
                      title: Text(item['item_name']),
                      subtitle: Text('${item['vendor_name']} • \$${double.parse(item['item_price']).toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => removeItem(item['item']),
                      ),
                    );
                  },
                ),
    );
  }
}
