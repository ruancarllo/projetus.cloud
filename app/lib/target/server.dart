import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:projetus_cloud/shared/network.dart';
import 'package:projetus_cloud/shared/cypherer.dart';
import 'package:projetus_cloud/shared/metadata.dart';
import 'package:projetus_cloud/shared/database.dart';

class Server {
  final Metadata metadata;
  final Directory storage;
  late Database database;

  HttpServer? httpServer;

  bool canSyncIP = true;
  String? lastIP;

  Server({required this.metadata, required this.storage}) {
    database= Database(
      githubToken: metadata.githubToken,
      gistId: metadata.databaseGistId,
      name: metadata.databaseName
    );
  }

  Future<void> startSyncingIP() async {
    final String decryptedIP = await Network.getExternalIP();
    final String encryptedIP = Cypherer.encryptText(decryptedIP, metadata.ipSecretKey, metadata.ipSecretIv);

    if (encryptedIP != lastIP) {  
      await database.setValue('ip', encryptedIP);
      
      lastIP = encryptedIP;
      print('Synced new IP: $decryptedIP');
    }

    if (canSyncIP) {
      Timer(const Duration(minutes: 10), startSyncingIP);
    }
  }

  Future<void> startListening() async {
    httpServer = await HttpServer.bind(InternetAddress.anyIPv4, 3434);
    print('Started server in port 3434');
    
    httpServer?.listen((HttpRequest request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        final WebSocket webSocket = await WebSocketTransformer.upgrade(request);

        webSocket.listen((dynamic encodedMessage) async {
          try {
            final Map decodedMessage = json.decode(encodedMessage);

            final String token = decodedMessage['token'];
            final String action = decodedMessage['action'];

            if (token != metadata.serverToken) {
              return await webSocket.close();
            }

            final List? entityRoute = decodedMessage['entityRoute'];
            final List? filesInfo = decodedMessage['filesInfo'];

            if (action == 'List-Entities' && entityRoute != null) await handleListEntitiesMessage(webSocket, entityRoute);
            if (action == 'Delete-Entity' && entityRoute != null) await handleDeleteEntityMessage(webSocket, entityRoute);
            if (action == 'Stream-Folder' && entityRoute != null) await handleStreamFolderMessage(webSocket, entityRoute);
            if (action == 'Create-Folder' && entityRoute != null) await handleCreateFolderMessage(webSocket, entityRoute);
            if (action == 'Stream-File' && entityRoute != null) await handleStreamFileMessage(webSocket, entityRoute);
            if (action == 'Write-Files' && filesInfo != null) await handleWriteFilesMessage(webSocket, filesInfo);
          }

          catch (exception) {
            print(exception);
          }
        });
      }

      else {
        return await request.response.close();
      }
    });
  }

  void stopSyncingIP() {
    canSyncIP = false;
  }

  void stopListening() {
    httpServer?.close(force: true);
  }

  Future<void> handleListEntitiesMessage(WebSocket webSocket, List directoryRoute) async {
    final String directoryPath = [storage.path, ...directoryRoute].join(Platform.pathSeparator);
    final List directoryContents = Directory(directoryPath).listSync();

    for (final FileSystemEntity entity in directoryContents) {
      final FileStat entityStat = await entity.stat();

      if (entityStat.type == FileSystemEntityType.file || entityStat.type == FileSystemEntityType.directory) {
        final List entityRoute = entity.path.replaceFirst(storage.path + Platform.pathSeparator, '').split(Platform.pathSeparator);
        final String entityType = entityStat.type.toString();

        final Map decodedEntityInfo = {
          'route': entityRoute,
          'type': entityType
        };

        final String encodedEntityInfo = json.encode(decodedEntityInfo);

        webSocket.add(encodedEntityInfo);
        print('Sent a $entityType info: ${entityRoute.join(Platform.pathSeparator)}');
      }
    }

    webSocket.add('end');
  }

  Future<void> handleDeleteEntityMessage(WebSocket webSocket, List entityRoute) async {
    final String entityPath = [storage.path, ...entityRoute].join(Platform.pathSeparator);
      final FileStat entityStat = await FileStat.stat(entityPath);

      if (entityStat.type == FileSystemEntityType.file) {
        await File(entityPath).delete();
      }

      if (entityStat.type == FileSystemEntityType.directory) {
        await Directory(entityPath).delete(recursive: true);
      }

      webSocket.add('end');
      print('Deleted a entity: ${entityRoute.join(Platform.pathSeparator)}');
  }

  Future<void> handleStreamFolderMessage(WebSocket webSocket, List folderRoute) async {
    final String folderPath = [storage.path, ...folderRoute].join(Platform.pathSeparator);
    final List folderContents = Directory(folderPath).listSync(recursive: true);

    for (final FileSystemEntity entity in folderContents) {
      final FileStat entityStat = await entity.stat();

      if (entityStat.type == FileSystemEntityType.file) {
        final List entityRoute = entity.path.replaceFirst(folderPath + Platform.pathSeparator, '').split(Platform.pathSeparator);
        final List<int> entityBytes = await File(entity.path).readAsBytes();

        final Map decodedFileInfo = {
          'route': entityRoute,
          'bytes': entityBytes
        };

        final String encodedFileInfo = json.encode(decodedFileInfo);

        webSocket.add(encodedFileInfo);
        print('Sent a file info: ${entityRoute.join(Platform.pathSeparator)}');
      }
    }

    webSocket.add('end');
  }

  Future<void> handleCreateFolderMessage(WebSocket webSocket, List folderRoute) async {
    final String folderPath = [storage.path, ...folderRoute].join(Platform.pathSeparator);
    final Directory directoryObject = Directory(folderPath);

    await directoryObject.create(recursive: true);
    print('Created a folder: ${folderRoute.join(Platform.pathSeparator)}');

    webSocket.add('end');
  }

  Future<void> handleStreamFileMessage(WebSocket webSocket, List fileRoute) async {
    final String filePath = [storage.path, ...fileRoute].join(Platform.pathSeparator);
    final List<int> fileBytes = await File(filePath).readAsBytes();

    webSocket.add(fileBytes);
    print('Sent a file: ${fileRoute.join(Platform.pathSeparator)}');

    webSocket.add('end');
  }

  Future<void> handleWriteFilesMessage(WebSocket webSocket, List filesInfo) async {
    for (final Map fileInfo in filesInfo) {
      final List fileRoute = fileInfo['route'];
      final List<int> fileBytes = fileInfo['bytes'].cast<int>();
      final String filePath = [storage.path, ...fileRoute].join(Platform.pathSeparator);

      final File file = File(filePath);

      await file.writeAsBytes(fileBytes);
      print('Wrote a folder: ${fileRoute.join(Platform.pathSeparator)}');
    }

    webSocket.add('end');
  }
}