import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Friend 1'),
            subtitle: Text('Last seen: 5 minutes ago'),
            trailing: Icon(Icons.location_on),
          ),
          ListTile(
            title: Text('Friend 2'),
            subtitle: Text('Last seen: 1 hour ago'),
            trailing: Icon(Icons.location_off),
          ),
          // Add more friends here
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add friend functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}