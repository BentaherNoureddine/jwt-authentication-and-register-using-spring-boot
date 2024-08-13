import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationHandler {
  static Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(

              title: const Center(child: Text("Location services is disabled")),
              content: const Text("Please enable the location service "),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ],
        );
      });
    };
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {

      return false;
    }
    return true;
  }

  static Future<Position?> getCurrentPosition(BuildContext context) async {
    try {
      final hasPermission = await handleLocationPermission(context);
      if (!hasPermission) return null;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placeMarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placeMarks[0];
      return "${place.street}, ${place.subLocality},${place.subAdministrativeArea}, ${place.postalCode}";
    } catch (e) {
      return null;
    }
  }
}