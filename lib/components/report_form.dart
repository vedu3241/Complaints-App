import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:logi_regi/api_service.dart';
import 'package:logi_regi/models/complaint.dart';
import 'package:quickalert/quickalert.dart';
import 'package:image_picker/image_picker.dart';

class ReportForm extends StatefulWidget {
  const ReportForm(
      {super.key, required this.userId, required this.changeIndex});
  final String userId;
  final Function changeIndex;
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
  String? Description;
  final TextEditingController _descriptionController = TextEditingController();

  bool isShowImage = false;
  final List<XFile>? _imageFiles = [];

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
    // print(_imageFiles);
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
      Complaint newComplaint = Complaint(lat, long, _selectedCategory,
          widget.userId, address, _imageFiles, Description);
      print(newComplaint);
      //passing Complaint to make POST req
      report(newComplaint);
    }
  }

  Future report(Complaint complaint) async {
    try {
      final Response res =
          await ApiService().submitReport(complaint, _imageFiles!);

      final responseData = jsonDecode(res.body);
      String message;

      if (res.statusCode == 201) {
        message = responseData['message'];
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: message,
          onConfirmBtnTap: widget.changeIndex(),
        );
      } else if (res.statusCode == 500) {
        message = responseData['message'];
        print(message);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: message,
        );
      } else if (res.statusCode == 400) {
        message = responseData['message'];
        print(message);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: message,
        );
      } else {
        print("Unexpected status code: ${res.statusCode}");
        // Handle the unexpected response here
      }
    } catch (e) {
      print("Error while processing response: $e");
      // Handle the error gracefully, e.g., display an error message to the user
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
    // List<Placemark> placemarks =
    //     await placemarkFromCoordinates(18.9512218, 72.8255601);
    // setState(() {
    //   address = placemarks[0].street! + " " + placemarks[0].country!;
    // });
    // print(address);

    // for (int i = 0; i < placemarks.length; i++) {
    //   print("INDEX $i ${placemarks[i]}");
    // }

// 18.9512218, 72.8255601
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        setState(() {
          address = placemarks[0].street! + " " + placemarks[0].country!;
        });
        print(address);
      } else {
        print("No placemarks found at your co-ordinates");
      }
    } catch (e) {
      print("Error: $e");
    }
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
    return Container(
      width: 320,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_imageFiles != null && _imageFiles!.isNotEmpty)
                InkWell(
                  onTap: () {
                    _showImagePreview();
                  },
                  child: DottedBorder(
                    padding: const EdgeInsets.all(10),
                    dashPattern: const [5, 5],
                    color: Colors.blue,
                    strokeWidth: 2,
                    child: const SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: Center(
                        child: Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Preview Images",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.remove_red_eye),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  _pickImage();
                },
                child: DottedBorder(
                  padding: const EdgeInsets.all(10),
                  dashPattern: const [5, 5],
                  color: Colors.orange,
                  strokeWidth: 2,
                  child: const SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Select Images",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.image, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField(
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black,
                  ),
                  // decoration: const InputDecoration(border: InputBorder.none),
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
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                onChanged: (value) => setState(() {
                  Description = value.toString();
                }),
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  hintText: "Description here..",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Address :",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
              address != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "$address",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color.fromARGB(179, 100, 98, 98),
                            fontSize: 16),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 5.0,
                      ),
                    ),
              const SizedBox(
                height: 8,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    print(_descriptionController.text);
                    if (_formKey.currentState!.validate()) {
                      print("validate");
                      submitReport();
                    } else {}
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.orange,
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Center(
                      child: Text(
                        "Report Now",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
