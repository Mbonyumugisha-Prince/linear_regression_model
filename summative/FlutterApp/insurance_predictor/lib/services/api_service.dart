import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // iOS simulator  → 127.0.0.1
  // Android emulator → 10.0.2.2
  // Physical device  → your Mac's local IP e.g. 192.168.x.x
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<Map<String, dynamic>> predictCharge({
    required int age,
    required String sex,
    required double bmi,
    required int children,
    required String smoker,
    required String region,
  }) async {
    final uri = Uri.parse('$baseUrl/predict');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'age': age,
        'sex': sex,
        'bmi': bmi,
        'children': children,
        'smoker': smoker,
        'region': region,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      final detail = error['detail'];
      if (detail is List) {
        throw Exception(detail.map((e) => e['msg']).join(', '));
      }
      throw Exception(detail?.toString() ?? 'Prediction failed');
    }
  }
}
