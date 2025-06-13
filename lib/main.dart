import 'package:flutter/material.dart';
import 'package:my_recipe_front/screens/home_screen.dart';
import 'package:my_recipe_front/screens/login_screen.dart';
import 'package:my_recipe_front/screens/order_screen.dart';
import 'package:my_recipe_front/screens/menu_details_screen.dart';
import 'package:my_recipe_front/screens/order_details_screen.dart';
import 'package:my_recipe_front/screens/client_register_screen.dart';
import 'package:my_recipe_front/screens/chief_register_screen.dart';
import 'package:my_recipe_front/screens/signup_choice_screen.dart';
import 'package:my_recipe_front/screens/favorite_screen.dart';
import 'package:my_recipe_front/screens/recent_orders_screen.dart';
import 'package:my_recipe_front/screens/cart_screen.dart'; // Ensure this file exists and contains CartScreen class
import 'package:my_recipe_front/screens/track_order_screen.dart';
import 'package:my_recipe_front/screens/profile_screen.dart';
import 'package:my_recipe_front/screens/create_menu_screen.dart';
import 'package:my_recipe_front/screens/vendor_menu_detail_screen.dart';
import 'package:my_recipe_front/screens/edit_menu_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Recipe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/menuDetails': (context) => const MenuDetailsScreen(),
        '/orders': (context) => const OrderScreen(),
        '/orderDetails': (context) => const OrderDetailsScreen(),
        '/signupChoice': (context) => const SignupChoiceScreen(),
        '/registerClient': (context) => const ClientRegisterScreen(),
        '/registerChief': (context) => const ChiefRegisterScreen(),
        '/favorites': (context) => const FavoriteScreen(),
'/recentOrders': (context) => const RecentOrdersScreen(),
        '/cart': (context) => const CartScreen(), 
        '/trackOrder': (context) => const TrackOrderScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/createMenu': (context) => const CreateMenuScreen(),
        '/vendorMenuDetails': (context) => const VendorMenuDetailScreen(),
        '/editMenu': (context) => const EditMenuScreen(),
      },
    );
  }
}
