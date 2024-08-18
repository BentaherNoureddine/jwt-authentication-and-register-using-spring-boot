import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/strings/constants.dart';
import '../../../core/utils/snack_bar_message.dart';
import '../entities/category_model.dart';
import '../repositories/LocationHandler.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  ReportScreenState createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  String? address;
  LatLng userPosition = const LatLng(0, 0);
  LatLng actionPosition = const LatLng(0, 0); // Initialize with a default value
  LatLng markedPosition = const LatLng(0, 0);
  File? _image;
  final ImagePicker _picker = ImagePicker();

  late GoogleMapController mapController;
  MapType _mapType = MapType.normal;
  Category? _category = Category.FIRE;

  Set<Marker> markers = {};

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // Decode JWT token
  static Map<String?, dynamic>? decodeJwt(String? token) {
    if (token == null) return null;
    try {
      final jwt = JWT.decode(token);
      return jwt.payload;
    } catch (e) {
      print("Error decoding JWT: $e");
      return null;
    }
  }

  // Create multipart file from image
  Future<http.MultipartFile?> createMultipartFile() async {
    if (_image != null) {
      return await http.MultipartFile.fromPath('image', _image!.path);
    }
    return null;
  }

  // Report creation
  void report(String description, String title) async {
    try {
      if (description.isEmpty || _image == null || title.isEmpty) {
        SnackBarMessage().showErrorSnackBar(
            message: "All fields are mandatory", context: context);
        return;
      }

      // Ensure actionPosition is not null
      if (actionPosition == const LatLng(0, 0)) {
        actionPosition = userPosition; // Default to userPosition if actionPosition is default
      }

      address = await LocationHandler.getAddressFromLatLng(actionPosition);

      final prefs = await SharedPreferences.getInstance();
      String? codedToken = prefs.getString('token');
      var token = decodeJwt(codedToken);
      String? email = token?['sub'];

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/reports/create'),
      );

      request.fields['category'] = _category!.name;
      request.fields['description'] = description;
      request.fields['title'] = title;
      request.fields['address'] = address.toString();
      request.fields['reporterId'] = email!;
      request.fields['location'] = actionPosition.toString();

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ));
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        SnackBarMessage().showSuccessSnackBar(
            message: "Report submitted successfully!", context: context);
      } else {
        SnackBarMessage().showErrorSnackBar(
            message: "Failed to submit report", context: context);
      }
    } catch (e) {
      print(e.toString());
      SnackBarMessage().showErrorSnackBar(
          message: "An error occurred. Please try again later.",
          context: context);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void addMarker(LatLng latLng) {
    // Log current actionPosition to debug
    print("Current action position before update: ${actionPosition.latitude}, ${actionPosition.longitude}");

    setState(() {
      // Add the new marker
      markers.add(
        Marker(
          markerId: const MarkerId("tapped_marker"),
          position: latLng,
          onTap: () {
            // Update actionPosition when a marker is tapped
            setState(() {
              markedPosition = latLng;
              actionPosition = latLng; // Update actionPosition
              // Log actionPosition after update
              print("Updated action position: ${actionPosition.latitude}, ${actionPosition.longitude}");
            });
          },
        ),
      );

      // Log markers count and details
      print("Markers count: ${markers.length}");
      for (var marker in markers) {
        print("Marker position: ${marker.position.latitude}, ${marker.position.longitude}");
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Section"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.brown,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              markers: markers,
              mapType: _mapType,
              initialCameraPosition: const CameraPosition(target: LatLng(44, 444), zoom: 11.0),
              onTap: addMarker,
            ),
          ),
          Positioned(
            right: 10,
            top: 210,
            child: FloatingActionButton(
              onPressed: () async {
                Position? position = await LocationHandler.getCurrentPosition(context);
                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(position!.latitude, position.longitude),
                      zoom: 14.0, // You can adjust the zoom level here
                    ),
                  ),
                );
                markers.clear();
                markers.add(
                  Marker(
                    markerId: const MarkerId("my_location"),
                    position: LatLng(position.latitude, position.longitude),
                    infoWindow: const InfoWindow(title: "My position"),
                  ),
                );
                setState(() {
                  userPosition = LatLng(position.latitude, position.longitude);
                });
              },
              child: const Icon(
                Icons.my_location,
                size: 20,
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 100,
            child: FloatingActionButton(
              backgroundColor: Colors.black45,
              onPressed: () {
                setState(() {
                  _mapType = _mapType == MapType.normal
                      ? MapType.satellite
                      : MapType.normal; // Toggle between normal and satellite
                });
              },
              child: const Icon(
                Icons.satellite_rounded,
                color: Colors.green,
                size: 20,
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 100,
                            color: Colors.greenAccent,
                            child: Center(
                              child: Text(
                                _image == null ? "Pick Image" : "Change Image",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_image != null)
                          SizedBox(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                        const SizedBox(height: 20),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Title is mandatory';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: "Title",
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                          ),
                          controller: titleController,
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          title: const Text("Fire"),
                          leading: Radio<Category>(
                            value: Category.FIRE,
                            groupValue: _category,
                            onChanged: (Category? value) {
                              setState(() {
                                _category = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text("Tree cutting"),
                          leading: Radio<Category>(
                            value: Category.TREE_CUTTING,
                            groupValue: _category,
                            onChanged: (Category? value) {
                              setState(() {
                                _category = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text("Trash"),
                          leading: Radio<Category>(
                            value: Category.TRASH,
                            groupValue: _category,
                            onChanged: (Category? value) {
                              setState(() {
                                _category = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Description is mandatory';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: "Description",
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                          ),
                          controller: descriptionController,
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            report(descriptionController.text.toString(),
                                titleController.text);
                          },
                          child: Container(
                            height: 50, // Fixed height for the button
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "Report",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
