import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<dynamic> vendors;
  List<dynamic> filteredVendors = [];
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final Map<String, String> _imageCache = {}; // Cache image paths

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    vendors = args?['menus'] ?? [];
    filteredVendors = vendors;
  }

  void updateSearch(String query) {
    setState(() {
      filteredVendors = vendors
          .where((vendor) => (vendor['vendorName'] ?? '')
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<String> getImagePathForVendor(String vendorName) async {
    if (_imageCache.containsKey(vendorName)) {
      return _imageCache[vendorName]!;
    }

    final assetPath = 'assets/images/$vendorName.jpg';
    try {
      await DefaultAssetBundle.of(context).load(assetPath);
      _imageCache[vendorName] = assetPath;
      return assetPath;
    } catch (e) {
      _imageCache[vendorName] = 'assets/images/menu3.jpg';
      return 'assets/images/menu3.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFF4A0D1F),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4A0D1F)),
              child: Center(
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.orange,
                    child: Text('N', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ),
            ),
            _buildDrawerItem('Home Page', Icons.home, () {
              Navigator.pop(context);
            }),
            _buildDrawerItem('Favorite', Icons.favorite, () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/favorites');
            }),
            _buildDrawerItem('Cart', Icons.shopping_cart, () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/cart');
            }),
            _buildDrawerItem('Recent Orders', Icons.history, () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/recentOrders');
            }),
            const Divider(color: Colors.white54),
            _buildDrawerItem('Sign Out', Icons.logout, () {
              Navigator.pushReplacementNamed(context, '/');
            }),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A0D1F),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: isSearching
            ? TextField(
                controller: searchController,
                focusNode: focusNode,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search vendors...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: updateSearch,
              )
            : const Text(
                'MY RECIPE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  filteredVendors = vendors;
                }
                isSearching = !isSearching;
              });
              if (!isSearching) {
                focusNode.unfocus();
              } else {
                focusNode.requestFocus();
              }
            },
          ),
        ],
      ),
      body: filteredVendors.isEmpty
          ? const Center(child: Text('No matching vendors found.'))
          : ListView.builder(
              itemCount: filteredVendors.length,
              itemBuilder: (context, vendorIndex) {
                final vendor = filteredVendors[vendorIndex];
                final vendorName = vendor['vendorName'] ?? 'Unknown Vendor';
                final menus = vendor['menus'] as List<dynamic>? ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        vendorName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    for (final menu in menus)
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/menuDetails',
                            arguments: {'vendorName': vendorName, 'menu': menu},
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              SizedBox(
                                height: 180,
                                width: double.infinity,
                                child: FutureBuilder<String>(
                                  future: getImagePathForVendor(vendorName),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    final imagePath = snapshot.data ?? 'assets/images/menu1.jpg';
                                    return Image.asset(
                                      imagePath,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(Icons.shopping_cart,
                                      color: Colors.black87, size: 20),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: const Color(0xFF000000).withAlpha(120),
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    menu['menuName'] ?? 'Unnamed Menu',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}
