import 'package:flutter/material.dart';
import 'package:my_recipe_front/screens/home_screen.dart';
import 'package:my_recipe_front/screens/login_screen.dart';
import 'package:my_recipe_front/screens/order_screen.dart';
import 'package:my_recipe_front/screens/menu_details_screen.dart';
import 'package:my_recipe_front/screens/order_details_screen.dart';
import 'package:my_recipe_front/screens/client_register_screen.dart';
import 'package:my_recipe_front/screens/chief_register_screen.dart';
import 'package:my_recipe_front/screens/signup_choice_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
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
      },
    );
  }
}
