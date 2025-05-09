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

String formatTime(String isoString) {
  try {
    final dateTime = DateTime.parse(isoString).toLocal();
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $ampm';
  } catch (e) {
    return '';
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
                        final customerName = order['customerName'] ?? 'Customer';
                        final orderId = order['orderId'] ?? '';
                        final totalPrice = order['totalOrderPrice']?.toStringAsFixed(2) ?? '0.00';
                        final orderDate = order['orderDate'] ?? '';
                        final time = formatTime(orderDate);

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: index == 0 ? Colors.red : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          elevation: 2,
child: ListTile(
  leading: CircleAvatar(
    radius: 24,
    backgroundColor: Colors.orange,
    child: Text(
      customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
      style: const TextStyle(color: Colors.white, fontSize: 20),
    ),
  ),
  title: Text(
    'Order #$orderId',
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(order['description'] ?? 'No details provided'),
      const SizedBox(height: 4),
      Text(
        '\$$totalPrice',
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
  trailing: Text(
    time,
    style: const TextStyle(color: Colors.grey, fontSize: 12),
  ),
  onTap: () {
    Navigator.pushNamed(context, '/orderDetails', arguments: order);
  },

                          ),
                        );
                      },
                    ),
    );
  }
}
