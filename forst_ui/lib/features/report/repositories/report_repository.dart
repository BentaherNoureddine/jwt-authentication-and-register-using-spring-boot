

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/strings/constants.dart';
import '../entities/report_model.dart';

class ReportRepository{




  static Future<List<Report>> loadReports() async{

    var response =  await http.get( Uri.parse('$apiUrl/reports/getAll'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Report.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reports');
    }
  }

}