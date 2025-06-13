// edit_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditMenuScreen extends StatefulWidget {
  const EditMenuScreen({Key? key}) : super(key: key);

  @override
  _EditMenuScreenState createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<Map<String, TextEditingController>> _newItems = [];
  List<dynamic> _existingItems = [];
  bool _isLoading = false;
  bool _initialized = false;

  // will stay null if args were bad
  int? _menuId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        // safe to extract
        _menuId = args['menuId'] as int?;
        _nameController.text = (args['menuName'] as String?) ?? '';
        _existingItems = List<dynamic>.from(args['items'] as List<dynamic>? ?? []);
      } else {
        // no valid args → go back immediately
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
        });
      }
      _initialized = true;
    }
  }

  void _addNewItem() {
    setState(() {
      _newItems.add({
        'name': TextEditingController(),
        'price': TextEditingController(),
        'description': TextEditingController(),
        'categories': TextEditingController(),
      });
    });
  }

  Future<void> _updateMenu() async {
    if (_menuId == null) return;
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Menu name is required')));
      return;
    }

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final url =
        // Uri.parse('http://127.0.0.1:8000/api/vendor/menus/$_menuId/');
        Uri.parse('http://172.20.10.3:8000/api/vendor/menus/$_menuId/');

    final payload = {
      'menu_name': _nameController.text,
      'new_items': _newItems.map((item) {
        return {
          'name': item['name']!.text,
          'price': double.tryParse(item['price']!.text) ?? 0.0,
          'description': item['description']!.text,
          'categories': item['categories']!
              .text
              .split(',')
              .map((c) => c.trim())
              .toList(),
        };
      }).toList(),
    };

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    setState(() => _isLoading = false);
    if (response.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // if we failed to grab menuId, show a placeholder
    if (_menuId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Menu')),
        body: const Center(child: Text('No menu selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Menu')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Items', style: TextStyle(fontSize: 16)),
                  ..._existingItems.map((item) => ListTile(
                        title: Text(item['itemName']),
                        subtitle:
                            Text('\LE${(item['price'] as num).toStringAsFixed(2)}'),
                      )),
                  const Divider(),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Menu Name'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Add New Items',
                          style: TextStyle(fontSize: 16)),
                      IconButton(icon: const Icon(Icons.add), onPressed: _addNewItem),
                    ],
                  ),
                  ..._newItems.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final ctrls = entry.value;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            TextField(
                              controller: ctrls['name'],
                              decoration:
                                  const InputDecoration(labelText: 'Name'),
                            ),
                            TextField(
                              controller: ctrls['price'],
                              decoration:
                                  const InputDecoration(labelText: 'Price'),
                              keyboardType: TextInputType.number,
                            ),
                            TextField(
                              controller: ctrls['description'],
                              decoration: const InputDecoration(
                                  labelText: 'Description'),
                            ),
                            TextField(
                              controller: ctrls['categories'],
                              decoration: const InputDecoration(
                                  labelText:
                                      'Categories (comma separated)'),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => setState(() {
                                  _newItems.removeAt(idx);
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateMenu,
                    child: const Text('Update Menu'),
                    style:
                        ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                ],
              ),
            ),
    );
  }
}
