import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_recipe_front/screens/checkout_screen.dart';
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
      // Uri.parse('http://172.20.10.3:8000/api/cart/'),
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
      // Uri.parse('http://172.20.10.3:8000/api/cart/item/$itemId/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (!mounted) return;

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

  Future<void> clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) return;

    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/cart/clear/'),
      // Uri.parse('http://172.20.10.3:8000/api/cart/clear/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      setState(() {
        cartItems.clear();
      });
    } else {
      developer.log('Failed to clear cart', name: 'CartScreen', error: response.body);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to clear cart.')),
      );
    }
  }

  Future<void> updateItemQuantity(int itemId, int newQuantity) async {
    if (newQuantity < 1) return; // Prevent quantity < 1

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/cart/item/$itemId/'),
      // Uri.parse('http://172.20.10.3:8000/api/cart/item/$itemId/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'quantity': newQuantity}),
    );

    if (response.statusCode == 200) {
      setState(() {
        for (var item in cartItems) {
          if (item['item'] == itemId) {
            item['quantity'] = newQuantity;
            break;
          }
        }
      });
    } else {
      developer.log('Failed to update quantity', name: 'CartScreen', error: response.body);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update quantity.')),
      );
    }
  }

Future<void> proceedToCheckout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You must be logged in to checkout.')),
    );
    return;
  }

  final response = await http.post(
    Uri.parse('http://127.0.0.1:8000/api/cart/checkout/'),
    // Uri.parse('http://172.20.10.3:8000/api/cart/checkout/'),
    headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "payment_method": "Cash", // You can make this dynamic later
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final Map<String, dynamic> orderData = responseData['order'];

    setState(() {
      cartItems.clear();
    });

    // Navigate to checkout screen with order data
    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(orderData: orderData),
      ),
    );
  } else {
    developer.log('Checkout failed', name: 'CartScreen', error: response.body);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checkout failed. Please try again.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: clearCart,
            tooltip: 'Clear Cart',
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty.'))
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final int itemId = item['item'];
                    final int quantity = item['quantity'];
                    return ListTile(
                      title: Text(item['item_name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item['vendor_name']} • LE${double.parse(item['item_price']).toStringAsFixed(2)}'),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => updateItemQuantity(itemId, quantity - 1),
                              ),
                              Text('$quantity'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => updateItemQuantity(itemId, quantity + 1),
                              ),
                            ],
                          )
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => removeItem(itemId),
                      ),
                    );
                  },
                ),
                bottomNavigationBar: cartItems.isNotEmpty
    ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: proceedToCheckout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Proceed to Checkout',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      )
    : null,

    );
  }
}
