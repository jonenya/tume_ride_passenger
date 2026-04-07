import 'package:http/http.dart' as http;
import 'dart:convert';

class GeocodingService {
  static const String apiKey = 'AIzaSyBAsxRsUOZzuGqkKT9ANtCHOIQqmGyqkJY';

  static Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    if (query.isEmpty) return [];

    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$apiKey'
      );

      final response = await http.get(url);
      print('Geocoding response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Geocoding API status: ${data['status']}');

        if (data['status'] == 'OK') {
          List<Map<String, dynamic>> results = [];
          for (var result in data['results']) {
            results.add({
              'name': result['formatted_address'].split(',').first,
              'address': result['formatted_address'],
              'lat': result['geometry']['location']['lat'],
              'lng': result['geometry']['location']['lng'],
            });
          }
          return results;
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          print('Geocoding API error: ${data['status']} - ${data.get('error_message', 'No message')}');
          return [];
        }
      }
      return [];
    } catch (e) {
      print('Geocoding error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          return {
            'name': result['formatted_address'].split(',').first,
            'address': result['formatted_address'],
            'lat': lat,
            'lng': lng,
          };
        }
      }
      return null;
    } catch (e) {
      print('Reverse geocoding error: $e');
      return null;
    }
  }
}