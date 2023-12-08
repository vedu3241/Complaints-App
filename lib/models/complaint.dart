// enum Category { , travel, leisure, work }

import 'package:image_picker/image_picker.dart';

class Complaint {
  String? ReporterId;
  String? Category;
  double? Latitude;
  double? Longitude;
  String? Address;
  String? Description;
  List<XFile>? images;

  Complaint(this.Latitude, this.Longitude, this.Category, this.ReporterId,
      this.Address, this.images, this.Description);
}
