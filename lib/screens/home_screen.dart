// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // ignore: unused_field
//   GoogleMapController? _mapController;
//   Position? _currentPosition;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   void _getCurrentLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     setState(() {
//       _currentPosition = position;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Proximity App')),
//       body: _currentPosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               onMapCreated: (controller) => _mapController = controller,
//               initialCameraPosition: CameraPosition(
//                 target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//                 zoom: 15,
//               ),
//               myLocationEnabled: true,
//             ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
//           BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
//         ],
//         onTap: (index) {
//           if (index == 1) {
//             Navigator.pushNamed(context, '/friends');
//           } else if (index == 2) {
//             Navigator.pushNamed(context, '/settings');
//           }
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String jwtToken;

  const HomeScreen({super.key, required this.jwtToken});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Map<String, dynamic>? _homeData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _getCurrentLocation();
    await _fetchData();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permissions are denied';
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Location permissions are permanently denied';
        _isLoading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
      _sendLocationToServer(position); // Send location to server
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location';
        _isLoading = false;
      });
    }
  }

// Method to send location to server
  Future<void> _sendLocationToServer(Position position) async {
    const url =
        'https://proximity-backend.onrender.com/update_location'; // Replace with your server URL

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user_id': 2, // Replace with actual user ID
        'latitude': position.latitude,
        'longitude': position.longitude,
      }),
    );

    if (response.statusCode == 200) {
      print('Location updated successfully');
    } else {
      print('Failed to update location');
    }
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://proximity-backend.onrender.com/home'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.jwtToken}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _homeData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load home data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load home data';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proximity App')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          child: _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude),
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                ),
        ),
        if (_homeData != null) _buildHomeData(),
      ],
    );
  }

  Widget _buildHomeData() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Home Data:', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Data from API: ${_homeData.toString()}'),
        ],
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/friends');
        break;
      case 2:
        Navigator.pushNamed(context, '/settings');
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// Mock fetchHomeData function (replace with your actual implementation)
Future<Map<String, dynamic>> fetchHomeData(String jwtToken) async {
  final response = await http.get(
    Uri.parse('https://proximity-backend.onrender.com/home'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load home data');
  }
}
