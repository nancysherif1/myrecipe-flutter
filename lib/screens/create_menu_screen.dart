import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CreateMenuScreen extends StatefulWidget {
  const CreateMenuScreen({Key? key}) : super(key: key);

  @override
  _CreateMenuScreenState createState() => _CreateMenuScreenState();
}

class _CreateMenuScreenState extends State {
  final TextEditingController _nameController = TextEditingController();
  final List<Map<String, TextEditingController>> _items = [];
  bool _isLoading = false;

  void _addItem() {
    setState(() {
      _items.add({
        'name': TextEditingController(),
        'price': TextEditingController(),
        'description': TextEditingController(),
        'categories': TextEditingController(),
      });
    });
  }

  Future _createMenu() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Menu name is required')));
      return;
    }
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    // final url = Uri.parse('http://127.0.0.1:8000/api/vendor/menus/');
    final url = Uri.parse('http://172.20.10.3:8000/api/vendor/menus/');
    final payload = {
      'menu_name': _nameController.text,
      'items':
          _items.map((item) {
            return {
              'name': item['name']!.text,
              'price': double.tryParse(item['price']!.text) ?? 0.0,
              'description': item['description']!.text,
              'categories':
                  item['categories']!.text
                      .split(',')
                      .map((c) => c.trim())
                      .toList(),
            };
          }).toList(),
    };
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    setState(() => _isLoading = false);
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu created successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${response.statusCode}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Menu')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Menu Name'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Items', style: TextStyle(fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addItem,
                        ),
                      ],
                    ),
                    ..._items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controllers = entry.value;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              TextField(
                                controller: controllers['name'],
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                ),
                              ),
                              TextField(
                                controller: controllers['price'],
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              TextField(
                                controller: controllers['description'],
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                ),
                              ),
                              TextField(
                                controller: controllers['categories'],
                                decoration: const InputDecoration(
                                  labelText: 'Categories (comma separated)',
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => setState(
                                        () => _items.removeAt(index),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _createMenu,
                      child: const Text('Create Menu'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
