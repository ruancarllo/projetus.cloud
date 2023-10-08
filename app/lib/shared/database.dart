import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';

class Database {
  late Uri gistApiUri;

  final String githubToken;
  final String gistId;
  final String name;

  static HttpClient httpClient = HttpClient();

  Database({required this.githubToken, required this.gistId, required this.name}) {
    gistApiUri = Uri.parse('https://api.github.com/gists/$gistId');
  }

  Future<Map> getContent() async {
    final Response gistResponse = await post(
      gistApiUri,
      headers: {
        'Authorization': 'Bearer $githubToken',
        'Accept': 'application/vnd.github+json'
      }
    );

    if (gistResponse.statusCode != HttpStatus.ok) {
      throw Exception('Network: Failed to get database values with status code ${gistResponse.statusCode}');
    }

    final Map responseBody = json.decode(gistResponse.body);

    return json.decode(responseBody['files']['$name.json']['content']);
  }

  Future<void> setValue(String key, dynamic value) async {
    final Map databaseContent = await getContent();

    databaseContent[key] = value;

    final Response gistResponse = await patch(
      gistApiUri,
      headers: {
        'Authorization': 'Bearer $githubToken',
        'Accept': 'application/vnd.github+json'
      },
      body: json.encode({
        'files': {
          '$name.json': {'content': json.encode(databaseContent)}
        }
      })
    );

    if (gistResponse.statusCode != HttpStatus.ok) {
      throw Exception('Network: Failed to set a database value with status code ${gistResponse.statusCode}');
    }
  }

  Future<dynamic> getValue(String key) async {
    final Map databaseContent = await getContent();

    return databaseContent[key];
  }
}