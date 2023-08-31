// enum Category { , travel, leisure, work }

import 'dart:io';

class Complaint {
  String? ReporterId;
  String? Category;
  double? Latitude;
  double? Longitude;
  String? Address;
  File? image;

  Complaint(this.Latitude, this.Longitude, this.Category, this.ReporterId,
      this.Address, this.image);
}
