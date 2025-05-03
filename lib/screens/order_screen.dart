// order_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = ModalRoute.of(context)?.settings.arguments as String?;
    if (token != null) {
      _fetchOrders(token);
    } else {
      setState(() {
        _error = 'Token missing';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchOrders(String token) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/vendor/orders/');
    final headers = {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        setState(() {
          _orders = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load orders';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching orders';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Orders List")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _orders.isEmpty
                  ? const Center(child: Text('No orders found.'))
                  : ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return ListTile(
                          title: Text('Order #${order['orderId']} - ${order['status']}'),
                          subtitle: Text('${order['customerName']} - \$${order['totalOrderPrice']}'),
                        );
                      },
                    ),
    );
  }
}
