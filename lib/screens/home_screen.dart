import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final List<dynamic> vendors = args?['menus'] ?? [];

    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFF4A0D1F), // Dark red/maroon
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF4A0D1F),
              ),
                    child: Center( // Center aligns the CircleAvatar properly
        child: SizedBox(
          width: 70, // Explicit width constraint
          height: 70, // Explicit height constraint
          child: CircleAvatar(
            radius: 24, // Enforcing a smaller circle
            backgroundColor: Colors.orange,
            child: Text(
              'N',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    ),

            _buildDrawerItem('Home Page', Icons.home, () {
              Navigator.pop(context); // Just close drawer
            }),
            _buildDrawerItem('Setting', Icons.settings, () {}),
            _buildDrawerItem('Favorite', Icons.favorite, () {}),
            _buildDrawerItem('Recent Orders', Icons.history, () {}),
            const Divider(color: Colors.white54),
           _buildDrawerItem('Sign Out', Icons.logout, () {
            Navigator.pushReplacementNamed(context, '/');
          }),
          ],
        ),
      ),
        appBar: AppBar(
          backgroundColor: const Color(0xFF4A0D1F), // Maroon color
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white), // Makes the drawer (toggle) icon white
          title: const Text(
            'MY RECIPE',
            style: TextStyle(
              color: Colors.white, // Makes title text white
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),

      body: vendors.isEmpty
          ? const Center(child: Text('No menu items available.'))
          : ListView.builder(
              itemCount: vendors.length,
              itemBuilder: (context, vendorIndex) {
                final vendor = vendors[vendorIndex];
                final vendorName = vendor['vendorName'] ?? 'Unknown Vendor';
                final menus = vendor['menus'] as List<dynamic>? ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                            arguments: {
                              'vendorName': vendorName,
                              'menu': menu,
                            },
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              SizedBox(
                                height: 180,
                                width: double.infinity,
                                child: Image.asset(
                                  'assets/images/menu1.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(Icons.shopping_cart, color: Colors.black87, size: 20),
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
