import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      developer.log('Token not found. User might not be logged in.', name: 'TrackOrderScreen');
      setState(() => isLoading = false);
      return;
    }

    // List of URLs to try (in order of preference)
    final List<String> urlsToTry = [
      'http://127.0.0.1:8000/api/customer/orders/',  // With trailing slash
      'http://127.0.0.1:8000/api/customer/orders',   // Without trailing slash
      'http://172.20.10.3:8000/api/customer/orders/', // Alternative IP with slash
      'http://172.20.10.3:8000/api/customer/orders',  // Alternative IP without slash
      'http://localhost:8000/api/customer/orders/',   // localhost with slash
      'http://localhost:8000/api/customer/orders',    // localhost without slash
    ];

    for (String url in urlsToTry) {
      try {
        developer.log('Trying URL: $url', name: 'TrackOrderScreen');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        developer.log('Response status: ${response.statusCode} for URL: $url', name: 'TrackOrderScreen');
        developer.log('Response body: ${response.body}', name: 'TrackOrderScreen');

        if (!mounted) return;

        if (response.statusCode == 200) {
          final responseBody = response.body;
          
          // Try to parse as different formats
          try {
            final decoded = json.decode(responseBody);
            
            List<dynamic> ordersList = [];
            
            // Handle different response formats
            if (decoded is List) {
              // Direct array response
              ordersList = decoded;
            } else if (decoded is Map<String, dynamic>) {
              // Object with orders array
              ordersList = decoded['orders'] ?? decoded['data'] ?? [];
            }
            
            setState(() {
              orders = ordersList;
              isLoading = false;
            });
            
            developer.log('Successfully loaded ${orders.length} orders from $url', name: 'TrackOrderScreen');
            return; // Success, exit the loop
          } catch (jsonError) {
            developer.log('JSON parsing error for $url: $jsonError', name: 'TrackOrderScreen');
            continue; // Try next URL
          }
        } else if (response.statusCode == 404) {
          developer.log('URL not found: $url', name: 'TrackOrderScreen');
          continue; // Try next URL
        } else {
          developer.log('Failed to fetch orders from $url - Status: ${response.statusCode}', 
                       name: 'TrackOrderScreen', error: response.body);
          continue; // Try next URL
        }
      } catch (e) {
        developer.log('Network error for $url: $e', name: 'TrackOrderScreen');
        continue; // Try next URL
      }
    }

    // If we reach here, all URLs failed
    setState(() => isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to connect to server. Please check if the server is running.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'delivered':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.check_circle;
      case 'delivered':
        return Icons.local_shipping;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track My Orders'),
        backgroundColor: const Color(0xFF4A0D1F),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No orders found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your order history will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final items = order['items'] as List<dynamic>? ?? [];
                      final status = order['status'] ?? 'Unknown';
                      final orderDate = order['orderDate'] ?? order['order_date'] ?? '';
                      final totalAmount = order['totalAmount']?.toString() ?? order['total_amount']?.toString() ?? '0.00';
                      final orderId = order['orderId']?.toString() ?? order['order_id']?.toString() ?? 'N/A';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order #$orderId',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      // ignore: deprecated_member_use
                                      color: _getStatusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _getStatusColor(status),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getStatusIcon(status),
                                          size: 16,
                                          color: _getStatusColor(status),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: _getStatusColor(status),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Order Date: ${orderDate.split('T')[0]}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Items:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...items.take(3).map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.restaurant_menu,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${item['itemName'] ?? item['item_name'] ?? 'Unknown Item'} x${item['quantity']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      'LE${item['subtotal']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                              if (items.length > 3)
                                Padding(
                                  padding: const EdgeInsets.only(left: 24),
                                  child: Text(
                                    '+${items.length - 3} more items',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'LE${double.parse(totalAmount).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A0D1F),
                                    ),
                                  ),
                                ],
                              ),
                              if (status.toLowerCase() == 'pending')
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // You can add order details navigation here
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Order details feature coming soon!'),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4A0D1F),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('View Details'),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}