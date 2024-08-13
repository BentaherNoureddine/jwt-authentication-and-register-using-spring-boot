import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:forst_ui/features/report/widgets/location_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/strings/constants.dart';
import '../../../core/utils/snack_bar_message.dart';
import '../entities/category_entity.dart';
import '../repositories/LocationHandler.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  TextEditingController descriptionController = TextEditingController();

  String? _currentAddress;
  Position? _currentPosition;

  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

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

  Future<http.MultipartFile?> createMultipartFile() async {
    if (_image != null) {
      return await http.MultipartFile.fromPath('image', _image!.path);
    }
    return null;
  }

  void report(String description) async {
    try {
      if (description.isEmpty || _image == null) {
        SnackBarMessage().showErrorSnackBar(
            message: "Description and image are mandatory", context: context);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      String? codedToken = prefs.getString('token');
      var token = decodeJwt(codedToken);
      String? email = token?['sub'];


      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/reports/create'),
      );

      // Add text fields
      request.fields['category'] = _category!.name;
      request.fields['description'] = description;
      request.fields['reporterId'] = email!;
      request.fields['location'] = _currentAddress!; // Set appropriate location


      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ));
      }

      // Send the request
      var response = await request.send();

      // Check response
      if (response.statusCode == 201) {
        SnackBarMessage().showSuccessSnackBar(
            message: "Report submitted successfully!", context: context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const LocationPage()));
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

  Category? _category = Category.FIRE; // Default category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Section"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.brown,
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 50,
                  color: Colors.blue,
                  child: Center(
                    child: Text(_image == null ? "Pick Image" : "Change Image"),
                  ),
                ),
              ),
              Center(
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
              const SizedBox(height: 20),
              if (_image != null)
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.file(_image!),
                ),
              //CATEGORY
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
                title: const Text("TRASH"),
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
              const SizedBox(height: 20),
              //DESCRIPTION
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'photo is mandatory';
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
                  report(descriptionController.text.toString());
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                    child: Text("Report"),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
