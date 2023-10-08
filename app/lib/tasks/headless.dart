import 'dart:io';
import 'dart:convert';
import 'package:projetus_cloud/target/server.dart';
import 'package:projetus_cloud/shared/metadata.dart';

void main() async {
  final String scriptPath = Platform.script.toFilePath();
  final String directoryPath = File(scriptPath).parent.path;

  final File settingsFile = File([directoryPath, 'settings.pcc'].join(Platform.pathSeparator));

  if (!await settingsFile.exists()) {
    return print('Coloque o arquivo "settings.pcc" na mesma pasta deste programa');
  }

  final String encodedSettings = await settingsFile.readAsString();
  final Map decodedSettings = json.decode(encodedSettings);

  final Server server = Server(
    metadata: Metadata.fromJson(encodedSettings),
    storage: Directory(decodedSettings['storagePath'])
  );

  await server.startListening();
  await server.startSyncingIP();
}