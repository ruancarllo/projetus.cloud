import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:projetus_cloud/shared/cypherer.dart';
import 'package:projetus_cloud/shared/metadata.dart';
import 'package:projetus_cloud/shared/database.dart';

class Client {
  final Metadata metadata;
  late Database database;

  WebSocket? webSocket;
  StreamController? streamController;

  Client({required this.metadata}) {
    database = Database(
      githubToken: metadata.githubToken,
      gistId: metadata.databaseGistId,
      name: metadata.databaseName
    );
  }

  Future<void> startServerConnection() async {
    final String encryptedIP = await database.getValue('ip');
    final String decryptedIP = Cypherer.decryptText(encryptedIP, metadata.ipSecretKey, metadata.ipSecretIv);

    webSocket = await WebSocket.connect('ws://$decryptedIP:3434');
    streamController = StreamController.broadcast();

    webSocket?.listen((data) {
      streamController?.add(data);
    });

    webSocket?.handleError((data) {
      streamController?.addError(data);
    });
  }

  void stopServerConnection() {
    webSocket?.close();
  }

  Future<List> listServerEntities(List directoryRoute) async {
    final Completer completer = Completer();
    final List entitiesInfo = [];

    webSocket?.add(json.encode({
      'token': metadata.serverToken,
      'action': 'List-Entities',
      'entityRoute': directoryRoute
    }));

    webSocket?.handleError((error) {
      completer.completeError(error);
    });

    final StreamSubscription? streamSubscription = streamController?.stream.listen((message) {
      if (message != 'end') {
        entitiesInfo.add(json.decode(message)); 
      }

      else {
        completer.complete();
      }
    });

    await completer.future;
    await streamSubscription?.cancel();


    entitiesInfo.sort((a, b) => a['route'][a['route'].length - 1].compareTo(b['route'][b['route'].length - 1]));
    entitiesInfo.sort((a, b) => b['type'].length.compareTo(a['type'].length));

    return entitiesInfo;  
  }

  Future<void> deleteServerEntity(List entityRoute) async {
    final Completer completer = Completer();

    webSocket?.add(json.encode({
      'token': metadata.serverToken,
      'action': 'Delete-Entity',
      'entityRoute': entityRoute
    }));

    webSocket?.handleError((error) {
      completer.completeError(error);
    });

    final StreamSubscription? streamSubscription = streamController?.stream.listen((message) {
      if (message == 'end') {
        completer.complete();
      }
    });

    await completer.future;
    await streamSubscription?.cancel();
  }

  Future<void> streamServerFolder(List folderRoute, Directory destination) async {
    final Completer completer = Completer();

    webSocket?.add(json.encode({
      'token': metadata.serverToken,
      'action': 'Stream-Folder',
      'entityRoute': folderRoute
    }));

    webSocket?.handleError((error) {
      completer.completeError(error);
    });

    final StreamSubscription? streamSubscription = streamController?.stream.listen((message) async {
      if (message != 'end') {
        final Map fileInfo = json.decode(message);

        final List fileRoute = fileInfo['route'];
        final String filePath = [destination.path, ...fileRoute].join(Platform.pathSeparator);

        final List directoryRoute = fileRoute.sublist(0, fileRoute.length - 1);
        final String directoryPath = [destination.path, ...directoryRoute].join(Platform.pathSeparator);

        final List<int> fileBytes = fileInfo['bytes'].cast<int>();
        
        await Directory(directoryPath).create(recursive: true);
        await File(filePath).writeAsBytes(fileBytes);
      }

      else {
        completer.complete();
      }
    });

    await completer.future;
    await streamSubscription?.cancel();
  }

  Future<void> createServerFolder(List folderRoute) async {
    final Completer completer = Completer();

    webSocket?.add(json.encode({
      'token': metadata.serverToken,
      'action': 'Create-Folder',
      'entityRoute': folderRoute
    }));

    webSocket?.handleError((error) {
      completer.completeError(error);
    });

    final StreamSubscription? streamSubscription = streamController?.stream.listen((message) {
      if (message == 'end') {
        completer.complete();
      }
    });

    await completer.future;
    await streamSubscription?.cancel();
  }

  Future<void> streamServerFile(List fileRoute, File destination) async {
    final Completer completer = Completer();

    webSocket?.add(json.encode({
      'token': metadata.serverToken,
      'action': 'Stream-File',
      'entityRoute': fileRoute
    }));

    webSocket?.handleError((error) {
      completer.completeError(error);
    });

    final StreamSubscription? streamSubscription = streamController?.stream.listen((message) async {
      if (message != 'end') {
        final List<int> fileBytes = message.cast<int>();

        await destination.writeAsBytes(fileBytes);
      }

      else {
        completer.complete();
      }
    });

    await completer.future;
    await streamSubscription?.cancel();
  }

  Future<void> writeServerFiles(List filesInfo) async {
    final Completer completer = Completer();

    webSocket?.add(json.encode({
      'token': metadata.serverToken,
      'action': 'Write-Files',
      'filesInfo': filesInfo
    }));

    webSocket?.handleError((error) {
      completer.completeError(error);
    });

    final StreamSubscription? streamSubscription = streamController?.stream.listen((message) {
      if (message == 'end') {
        completer.complete();
      }
    });

    await completer.future;
    await streamSubscription?.cancel();
  }
}