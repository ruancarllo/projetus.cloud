import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';

class Network {
  static Uri ipinfoApiUri = Uri.parse('https://ipinfo.io/json');

  static HttpClient httpClient = HttpClient();

  static Future<String> getExternalIP() async {
    final Response ipinfoResponse = await get(ipinfoApiUri);

    if (ipinfoResponse.statusCode != HttpStatus.ok) {
      throw Exception('Network: Failed to get external IP with status code ${ipinfoResponse.statusCode}');
    }

    final Map responseBody = json.decode(ipinfoResponse.body);

    return responseBody['ip'];
  }
}