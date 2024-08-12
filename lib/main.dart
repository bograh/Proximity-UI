import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proximity App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(jwtToken: 'your_jwt_token_here'),
        '/friends': (context) => const FriendsScreen(),
        '/settings': (context) => const SettingsScreen(),
        // '/login': (context) => const LoginScreen(),
      },
    );
  }
}