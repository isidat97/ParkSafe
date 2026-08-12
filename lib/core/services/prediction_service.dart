import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<double?> predictAvailability(String locationId, int hour) async {
    try {
      final url = Uri.parse('$baseUrl/predict?location_id=$locationId&hour=$hour');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prediction = data['predicted_availability_percentage'];
        if (prediction is int) {
          return prediction.toDouble();
        } else if (prediction is double) {
          return prediction;
        }
      }
      return null;
    } catch (e) {
      // Return null on failure (e.g., Python server not running)
      return null;
    }
  }
}
