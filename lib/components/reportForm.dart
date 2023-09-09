import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:logi_regi/models/complaint.dart';

import 'package:quickalert/quickalert.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReportForm extends StatefulWidget {
  const ReportForm({super.key, required this.userId});
  final String userId;
  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  //set Default Category
  String _selectedCategory = "Emergency";
  final _formKey = GlobalKey<FormState>();
  double? lat;
  double? long;
  String? address;

  bool isShowImage = false;
  final List<XFile>? _imageFiles = [];

  // SINGLE IMAGE CODE
  // Future<void> _pickImage(ImageSource source) async {
  //   final picker = ImagePicker();
  //   final pickedImage = await picker.pickImage(source: source);

  //   if (pickedImage != null) {
  //     setState(() {
  //       _imageFile = File(pickedImage.path);
  //     });
  //   }
  // }

  // MULTIPLE IMAGE CODE
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedImages = await picker.pickMultiImage();

    if (pickedImages.isNotEmpty) {
      _imageFiles!.addAll(
        pickedImages.map(
          (pickedImage) => XFile(pickedImage.path),
        ),
      );
      setState(() {});
    }
  }

  void submitReport() {
    //checking for null
    if (lat == null || long == null || address == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Please make sure your location is on"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Okay"),
            )
          ],
        ),
      );
    }
    //if image not found show error
    else if (_imageFiles == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Can not proceed without image!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Okay"),
            )
          ],
        ),
      );
    } else {
      //Creating new complaint obj
      Complaint newComplaint = Complaint(
          lat, long, _selectedCategory, widget.userId, address, _imageFiles);
      print(newComplaint);
      //passing Complaint to make POST req
      report(newComplaint);
    }
  }

  Future report(Complaint complaint) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.0.103:8000/submitReport'),
    );

    // var res = await http.post(
    //   Uri.parse('http://192.168.0.103:8000/submitReport'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8; multipart/form-data',
    //   },
    //   body: jsonEncode(
    //     <String, Object?>{
    //       'ReporterId': complaint.ReporterId,
    //       'Category': complaint.Category,
    //       'Latitude': complaint.Latitude,
    //       'Longitude': complaint.Longitude,
    //       'Address': complaint.Address,
    //       'reportImg': _imageFile,
    //     },
    //   ),
    // );

    request.fields['ReporterId'] = complaint.ReporterId!;
    request.fields['Category'] = complaint.Category!;
    request.fields['Latitude'] = complaint.Latitude.toString();
    request.fields['Longitude'] = complaint.Longitude.toString();
    request.fields['Address'] = complaint.Address!;

    // if (_imageFile != null) {
    //   request.files.add(
    //     await http.MultipartFile.fromPath('reportImg', _imageFile!.path),
    //   );
    // }

    // MULTIPLE IMAGE CODE
    print(_imageFiles == null);
    if (_imageFiles != null) {
      for (var imageFile in _imageFiles!) {
        request.files.add(
          await http.MultipartFile.fromPath('reportImages', imageFile.path),
        );
      }
    } else {
      print("error in report function :)");
    }

    var streamedResponse = await request.send();
    var res = await http.Response.fromStream(streamedResponse);

    final responseData = jsonDecode(res.body);
    String message;

    if (res.statusCode == 201) {
      message = responseData['message'];
      // ignore: use_build_context_synchronously
      QuickAlert.show(
        context: context,
        // onConfirmBtnTap: () {},
        type: QuickAlertType.success,
        text: message,
      );
    }
    //if found error
    if (res.statusCode == 500) {
      message = responseData['message'];
      print(message);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: message,
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

//For convert lat long to address
  getAddress(lat, long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    setState(() {
      address = placemarks[0].street! + " " + placemarks[0].country!;
    });

    // for (int i = 0; i < placemarks.length; i++) {
    //   print("INDEX $i ${placemarks[i]}");
    // }
  }

  getLatLong() {
    Future<Position> data = _determinePosition();
    data.then((value) {
      print("value $value");
      setState(() {
        lat = value.latitude;
        long = value.longitude;
      });

      getAddress(value.latitude, value.longitude);
    }).catchError((error) {
      print("Error $error");

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error"),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Okay"),
            )
          ],
        ),
      );
    });
  }

  void _showImagePreview() {
    if (_imageFiles != null && _imageFiles!.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //Make dialog BG transparent
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Image Preview'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: _imageFiles!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.file(
                      File(_imageFiles![index].path),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    getLatLong();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // if (_imageFile != null &&
            //     showImagePreview) // Show image preview when 'showImagePreview' is true
            //   Image.file(
            //     _imageFile!,
            //     height: 200,
            //     width: 200,
            //   ),

            // Show the preview button when there are selected images

            if (_imageFiles != null && _imageFiles!.isNotEmpty)
              ElevatedButton(
                onPressed: _showImagePreview,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.green,
                  ),
                ),
                child: const SizedBox(
                  width: 130,
                  child: Row(
                    children: [
                      Text(
                        "Preview Images",
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Icon(Icons.photo),
                    ],
                  ),
                ),
              ),

            // if (_imageFiles != null)
            //   SizedBox(
            //     height: 200,
            //     child: GridView.builder(
            //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //         crossAxisCount: 2,
            //         childAspectRatio: 1 / 2,
            //         crossAxisSpacing: 15,
            //         mainAxisSpacing: 0,
            //       ),
            //       itemCount: _imageFiles!.length,
            //       itemBuilder: (BuildContext context, int index) {
            //         return Image.file(
            //           File(_imageFiles![index].path),
            //         );
            //       },
            //     ),
            //   ),

            ElevatedButton(
              onPressed: () {
                _pickImage();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blue,
                ),
              ),
              child: const SizedBox(
                width: 120,
                child: Row(
                  children: [
                    Text(
                      "Select Images",
                      style: TextStyle(color: Colors.white),
                    ),
                    Spacer(),
                    Icon(Icons.image),
                  ],
                ),
              ),
            ),

            DropdownButton(
              value: _selectedCategory,
              items: const [
                DropdownMenuItem(
                  value: "Emergency",
                  child: Text("Emergency"),
                ),
                DropdownMenuItem(
                  value: "Pot Hole",
                  child: Text("Pot Hole"),
                ),
                DropdownMenuItem(
                  value: "Dead Tree",
                  child: Text("Dead Tree"),
                ),
                DropdownMenuItem(
                  value: "Sewage Water",
                  child: Text("Sewage Water"),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedCategory = value.toString();
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            const Text("Address :"),
            address != null
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      "$address",
                      textAlign: TextAlign.center,
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: CircularProgressIndicator(
                      strokeWidth: 5.0,
                    ),
                  ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  print("validate");
                  submitReport();
                } else {}
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                child: Text("Report"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
