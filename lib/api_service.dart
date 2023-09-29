import 'dart:convert';

import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:logi_regi/models/complaint.dart';
import 'package:logi_regi/models/user.dart';

class ApiService {
  final baseUrl = 'http://192.168.0.103:8000';

  Future<Response> saveLogin(User user) async {
    var res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, String>{
          'email': user.email,
          'password': user.password,
        },
      ),
    );
    return res;
  }

  Future<Response> saveRegister(User user) async {
    var res = await http.post(
      // 10.0.2.2
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, String>{
          'email': user.email,
          'password': user.password,
        },
      ),
    );
    return res;
  }

  Future<Response> submitReport(
      Complaint complaint, List<XFile> imageFiles) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/submitReport'),
    );

    request.fields['ReporterId'] = complaint.ReporterId!;
    request.fields['Category'] = complaint.Category!;
    request.fields['Latitude'] = complaint.Latitude.toString();
    request.fields['Longitude'] = complaint.Longitude.toString();
    request.fields['Address'] = complaint.Address!;

    for (var imageFile in imageFiles) {
      request.files.add(
        await http.MultipartFile.fromPath('reportImages', imageFile.path),
      );
    }

    var streamedResponse = await request.send();
    var res = await http.Response.fromStream(streamedResponse);

    return res;
  }

  Future<Response> getReports(String userId) async {
    var res = await http.post(
      Uri.parse('$baseUrl/getReports'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        <String, Object?>{
          'userId': userId,
        },
      ),
    );
    return res;
  }
}
