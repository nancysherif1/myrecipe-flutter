// profile_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> vendorInfo = {};
  List<dynamic> menus = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchVendorMenus();
  }

  Future<void> fetchVendorMenus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        setState(() {
          error = 'Token not found. Please login again.';
          isLoading = false;
        });
        return;
      }

      // For Phone/Emulator:
      final url = Uri.parse('http://172.20.10.3:8000/api/vendor/menus/');
      // For Web:
      // final url = Uri.parse('http://127.0.0.1:8000/api/vendor/menus/');

      final response = await http.get(url, headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      });

      developer.log('Response status: ${response.statusCode}', name: 'ProfileScreen');
      developer.log('Response body: ${response.body}', name: 'ProfileScreen');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          vendorInfo = data['vendorInfo'] ?? {};
          menus = data['menus'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load menus (status ${response.statusCode}).';
          isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error fetching vendor menus: $e', name: 'ProfileScreen');
      if (mounted) {
        setState(() {
          error = 'Failed to connect to server.';
          isLoading = false;
        });
      }
    }
  }

  Future<void> deleteMenu(int menuId, String menuName) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    // final url = Uri.parse('http://127.0.0.1:8000/api/vendor/menus/$menuId/');
    final url = Uri.parse('http://172.20.10.3:8000/api/vendor/menus/$menuId/');
    final response = await http.delete(url, headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      setState(() {
        menus.removeWhere((m) => m['menuId'] == menuId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "$menuName"')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete (status ${response.statusCode})')),
      );
    }
  }

  String formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Profile'),
        backgroundColor: const Color(0xFF4A0D1F),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A0D1F),
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/createMenu')
            .then((_) => fetchVendorMenus()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(error!, style: const TextStyle(fontSize: 16, color: Colors.red), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            error = null;
                          });
                          fetchVendorMenus();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A0D1F),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      isLoading = true;
                      error = null;
                    });
                    await fetchVendorMenus();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vendor Info
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: const Color(0xFF4A0D1F),
                                  child: Text(
                                    (vendorInfo['vendorName'] ?? 'V')[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(vendorInfo['vendorName'] ?? 'Unknown Vendor',
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(vendorInfo['location'] ?? 'No location', style: const TextStyle(color: Colors.grey)),
                                      ]),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(vendorInfo['workingHours'] ?? 'No hours', style: const TextStyle(color: Colors.grey)),
                                      ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Menus Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('My Menus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('${menus.length} menu${menus.length != 1 ? 's' : ''}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Menus List
                        menus.isEmpty
                            ? Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    children: [
                                      Icon(Icons.restaurant_menu, size: 48, color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      const Text('No menus available', style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: menus.map((menu) {
                                  final items = menu['items'] as List<dynamic>? ?? [];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Title + Actions
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(menu['menuName'] ?? 'Unnamed Menu',
                                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.remove_red_eye),
                                                    onPressed: () => Navigator.pushNamed(
                                                      context,
                                                      '/vendorMenuDetails',
                                                      arguments: menu['menuId'],
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.edit),
                                                    onPressed: () => Navigator.pushNamed(
                                                      context,
                                                      '/editMenu',
                                                      arguments: {
                                                        'menuId': menu['menuId'],
                                                        'menuName': menu['menuName'],
                                                        'items': menu['items'],
                                                      },
                                                    ).then((_) => fetchVendorMenus()),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                                    onPressed: () async {
                                                      final confirmed = await showDialog<bool>(
                                                        context: context,
                                                        builder: (ctx) => AlertDialog(
                                                          title: const Text('Delete menu?'),
                                                          content: Text('Delete "${menu['menuName']}" and all its items?'),
                                                          actions: [
                                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                                                          ],
                                                        ),
                                                      );
                                                      if (confirmed == true) {
                                                        deleteMenu(menu['menuId'], menu['menuName']);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          if (menu['date'] != null) ...[
                                            const SizedBox(height: 8),
                                            Text('Date: ${formatDate(menu['date'])}', style: const TextStyle(color: Colors.grey)),
                                          ],
                                          const SizedBox(height: 16),

                                          if (items.isNotEmpty) ...[
                                            const Text('Items:', style: TextStyle(fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 8),
                                            ...items.map((item) => Container(
                                                  margin: const EdgeInsets.only(bottom: 8),
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[50],
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.grey[200]!),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(child: Text(item['itemName'] ?? '')),
                                                          Text('\LE${(item['price'] as num).toStringAsFixed(2)}',
                                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A0D1F))),
                                                        ],
                                                      ),
                                                      if ((item['description'] as String?)?.isNotEmpty == true) ...[
                                                        const SizedBox(height: 4),
                                                        Text(item['description']!, style: const TextStyle(color: Colors.grey)),
                                                      ],
                                                      if ((item['categories'] as List?)?.isNotEmpty == true) ...[
                                                        const SizedBox(height: 8),
                                                        Wrap(
                                                          spacing: 4,
                                                          runSpacing: 4,
                                                          children: (item['categories'] as List)
                                                              .map<Widget>((c) => Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.blue[100],
                                                                      borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                    child: Text(c.toString(), style: const TextStyle(color: Colors.blueAccent)),
                                                                  ))
                                                              .toList(),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                )),
                                          ] else ...[
                                            const Text('No items in this menu', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
