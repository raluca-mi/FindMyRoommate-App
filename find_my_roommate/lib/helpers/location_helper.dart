import 'package:http/http.dart' as http;
import 'dart:convert';

// ignore: constant_identifier_names
const GOOGLE_API_KEY = '<API_KEY>';

class LocationHelper {
  static String generateLocationPreviewImage(
      {double? latitude, double? longitude}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  static Future<String> getPlaceAddress(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$GOOGLE_API_KEY';
    final response = await http.get(Uri.parse(url));
    return json.decode(response.body)['results'][0]['formatted_address'];
  }

  //get address components from google maps api
  static Future<Map<String, String>> getAddressComponents(
      double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$GOOGLE_API_KEY';
    final response = await http.get(Uri.parse(url));
    final addressComponents = json.decode(response.body)['results'][0]
        ['address_components'] as List<dynamic>;
    final Map<String, String> address = {};
    for (final component in addressComponents) {
      final types = component['types'] as List<dynamic>;
      if (types.contains('street_number')) {
        address['street_number'] = component['long_name'] as String;
      }
      if (types.contains('route')) {
        address['route'] = component['long_name'] as String;
      }
      if (types.contains('locality')) {
        address['locality'] = component['long_name'] as String;
      }
      if (types.contains('administrative_area_level_1')) {
        address['administrative_area_level_1'] =
            component['long_name'] as String;
      }
      if (types.contains('country')) {
        address['country'] = component['long_name'] as String;
      }
      if (types.contains('postal_code')) {
        address['postal_code'] = component['long_name'] as String;
      }
    }
    return address;
  }
}
