import 'dart:convert';

class Metadata {
  late String githubToken;

  late String databaseGistId;
  late String databaseName;

  late String ipSecretKey;
  late String ipSecretIv;

  late String serverToken;

  Metadata.fromJson(String encodedMetadata) {
    final Map decodedMetadata = json.decode(encodedMetadata);

    githubToken = decodedMetadata['githubToken'];
    databaseGistId = decodedMetadata['databaseGistId'];
    databaseName = decodedMetadata['databaseName'];
    ipSecretKey = decodedMetadata['ipSecretKey'];
    ipSecretIv = decodedMetadata['ipSecretIv'];
    serverToken = decodedMetadata['serverToken'];
  }
}