// vendor_menu_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VendorMenuDetailScreen extends StatefulWidget {
  const VendorMenuDetailScreen({super.key});
  @override
  _VendorMenuDetailScreenState createState() => _VendorMenuDetailScreenState();
}

class _VendorMenuDetailScreenState extends State<VendorMenuDetailScreen> {
  Map<String, dynamic>? menu;
  bool isLoading = true;
  int? menuId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    menuId = ModalRoute.of(context)!.settings.arguments as int;
    _fetchMenu(menuId!);
  }

  Future<void> _fetchMenu(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    // final url = Uri.parse('http://127.0.0.1:8000/api/vendor/menus/$id/');
    final url = Uri.parse('http://172.20.10.3:8000/api/vendor/menus/$id/');
    final res = await http.get(url, headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    });
    if (res.statusCode == 200) {
      setState(() {
        menu = jsonDecode(res.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteItem(int itemId, String itemName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "$itemName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Deleting item...'),
            ],
          ),
        );
      },
    );

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      // final url = Uri.parse('http://127.0.0.1:8000/api/vendor/menus/$menuId/items/$itemId/');
      final url = Uri.parse('http://172.20.10.3:8000/api/vendor/menus/$menuId/items/$itemId/');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Item deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the menu data
        _fetchMenu(menuId!);
      } else if (response.statusCode == 400) {
        // Handle case where item can't be deleted due to existing orders
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['error'] ?? 'Cannot delete item'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete item. Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Details')),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : menu == null
          ? const Center(child: Text('Failed to load'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu!['menuName'] ?? '', 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  Text('Items (${menu!['itemCount']})'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: (menu!['items'] as List).map((item) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(item['itemName']),
                          subtitle: Text('\LE${item['price'].toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteItem(
                              item['itemId'] ?? item['id'], // Handle different possible key names
                              item['itemName'],
                            ),
                            tooltip: 'Delete item',
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}