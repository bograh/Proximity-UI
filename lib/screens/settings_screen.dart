import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myapp/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _locationSharing = true;
  bool _notifications = true;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _logout() async {
    try {
      await _storage.delete(key: 'jwt_token'); // Clear the stored token
      // Navigator.pushReplacementNamed(context, '/login');
      Navigator.pushReplacementNamed(context, '/login', arguments: const LoginScreen() as String);
    } catch (e) {
      // Handle potential errors, such as storage issues or navigation failures
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Location Sharing'),
            value: _locationSharing,
            onChanged: (value) {
              setState(() {
                _locationSharing = value;
              });
              // Implement location sharing toggle logic
            },
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            value: _notifications,
            onChanged: (value) {
              setState(() {
                _notifications = value;
              });
              // Implement notifications toggle logic
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
