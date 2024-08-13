import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


import '../repositories/LocationHandler.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String? _currentAddress;
  Position? _currentPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location Page")),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('LAT: ${_currentPosition?.latitude ?? ""}'),
              Text('LNG: ${_currentPosition?.longitude ?? ""}'),
              Text('ADDRESS: ${_currentAddress ?? ""}'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  try {
                    _currentPosition = await LocationHandler.getCurrentPosition(context);
                    if (_currentPosition != null) {
                      _currentAddress = await LocationHandler.getAddressFromLatLng(_currentPosition!);
                      setState(() {});
                    } else {
                      // Handle the case where location is not available
                      print("Location permission denied or could not get location!");
                    }
                  } catch (e) {
                    print("Error getting location: $e");
                  }
                },

                child: const Text("Get Current Location"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}