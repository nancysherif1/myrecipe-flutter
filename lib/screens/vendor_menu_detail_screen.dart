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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final menuId = ModalRoute.of(context)!.settings.arguments as int;
    _fetchMenu(menuId);
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
                  Text(menu!['menuName'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Items (${menu!['itemCount']})'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: (menu!['items'] as List).map((item) => ListTile(
                        title: Text(item['itemName']),
                        subtitle: Text('\LE${item['price'].toStringAsFixed(2)}'),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
