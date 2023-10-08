import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projetus_cloud/shared/metadata.dart';

class Composer {
  static Future<Metadata> fetchMetadata() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final bool? wasConfigured = preferences.getBool('wasConfigured');

    return (wasConfigured == true) ? await Composer.getMetadata() : await Composer.setMetadata();
  }

  static Future<Metadata> setMetadata() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
      dialogTitle: 'Selecione um arquivo de configuração',
      allowMultiple: false
    );

    if (filePickerResult == null) return Composer.setMetadata();

    final String? filePath = filePickerResult.files[0].path;
    
    if (filePath == null) return Composer.setMetadata();
    
    final String encodedMetadata = await File(filePath).readAsString();

    final Metadata metadata = Metadata.fromJson(encodedMetadata);
    
    await preferences.setString('githubToken', metadata.githubToken);
    await preferences.setString('databaseGistId', metadata.databaseGistId);
    await preferences.setString('databaseName', metadata.databaseName);
    await preferences.setString('ipSecretKey', metadata.ipSecretKey);
    await preferences.setString('ipSecretIv', metadata.ipSecretIv);
    await preferences.setString('serverToken', metadata.serverToken);

    await preferences.setBool('wasConfigured', true);

    return metadata;
  }

  static Future<Metadata> getMetadata() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final Map decodedMetadata = {
      'githubToken': preferences.getString('githubToken'),
      'databaseGistId': preferences.getString('databaseGistId'),
      'databaseName': preferences.getString('databaseName'),
      'ipSecretKey': preferences.getString('ipSecretKey'),
      'ipSecretIv': preferences.getString('ipSecretIv'),
      'serverToken': preferences.getString('serverToken'),
    };

    final String encodedMetadata = json.encode(decodedMetadata);

    return Metadata.fromJson(encodedMetadata);
  }

  static Future<void> resetMetadata() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.remove('githubToken');
    await preferences.remove('databaseGistId');
    await preferences.remove('databaseName');
    await preferences.remove('ipSecretKey');
    await preferences.remove('ipSecretIv');
    await preferences.remove('serverToken');
    await preferences.remove('wasConfigured');
  }
}