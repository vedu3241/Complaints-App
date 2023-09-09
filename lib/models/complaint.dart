// enum Category { , travel, leisure, work }

import 'dart:io';

import 'package:image_picker/image_picker.dart';

class Complaint {
  String? ReporterId;
  String? Category;
  double? Latitude;
  double? Longitude;
  String? Address;
  List<XFile>? images;

  Complaint(this.Latitude, this.Longitude, this.Category, this.ReporterId,
      this.Address, this.images);
}
