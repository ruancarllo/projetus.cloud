import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:projetus_cloud/target/client.dart';
import 'package:projetus_cloud/shared/metadata.dart';
import 'package:projetus_cloud/shared/composer.dart';
import 'package:projetus_cloud/widgets/others/entity_bar.dart';
import 'package:projetus_cloud/widgets/buttons/glpyph_button.dart';
import 'package:projetus_cloud/widgets/buttons/action_button.dart';
import 'package:projetus_cloud/widgets/dialogs/prompt_dialog.dart';
import 'package:projetus_cloud/widgets/dialogs/confirm_dialog.dart';
import 'package:projetus_cloud/widgets/dialogs/message_dialog.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  @override UserScreenState createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  Client? client;

  String directoryName = defaultDirectoryName;
  List directoryRoute = [];
  List serverEntities = [];
  
  static const String defaultDirectoryName = 'Disco virtual';

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliente'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlyphButton(
                  iconData: Icons.subdirectory_arrow_right,
                  iconColor: Colors.black,
                  action: returnDirectory,
                ),
                const SizedBox(width: 15),
                Text(
                  directoryName,
                  style: const TextStyle(
                    fontSize: 25
                  )
                ),
                const Spacer(flex: 1),
                ActionButton(
                  actionName: 'Adicionar arquivos',
                  action: () => requestFileAddition(context)
                ),
                const SizedBox(width: 15),
                ActionButton(
                  actionName: 'Criar pasta',
                  action: () => requestFolderCreation(context)
                )
              ]
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: serverEntities.length,
                itemBuilder:(context, index) {
                  final String entityType = serverEntities[index]['type'];
                  final List entityRoute = serverEntities[index]['route'];
                  final String entityName = entityRoute.last;
            
                  late IconData entityIconData;
            
                  if (entityType == 'directory') entityIconData = Icons.folder;
                  if (entityType == 'file') entityIconData = Icons.file_copy;

                  return Row(
                    children: [
                      EntityBar(
                        name: entityName,
                        iconData: entityIconData,
                        click: () {
                          if (entityType == 'directory') enterDirectory(entityName);
                          if (entityType == 'file') requestEntitySaving(context, entityType, entityRoute, entityName);
                        }
                      ),
                      const SizedBox(width: 15),
                      GlyphButton(
                        iconData: Icons.download,
                        iconColor: Theme.of(context).highlightColor,
                        action: () => requestEntitySaving(context, entityType, entityRoute, entityName),
                      ),
                      GlyphButton(
                        iconData: Icons.delete,
                        iconColor: Theme.of(context).highlightColor,
                        action: () => requestEntityDeletion(context, entityRoute, entityName),
                      )
                    ],
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 10)
              )
            )
          ]
        )
      )
    );
  }

  @override void initState() {
    super.initState();

    Composer.fetchMetadata().then((Metadata metadata) async {
      client = Client(
        metadata: metadata
      );

      await client?.startServerConnection();
      await enterDirectory(null);
    });
  }

  @override void dispose() {
    super.dispose();
    client?.stopServerConnection();
  }

  void requestFileAddition(BuildContext context) {
    FilePicker.platform.pickFiles(
      dialogTitle: 'Selecione um arquivo',
      allowMultiple: true
    ).then((FilePickerResult? result) {
      if (result == null) return;

      showDialog(
        context: context,
        builder: (context) {
          return const MessageDialog(
            message: 'Adicionando arquivos',
            iconData: Icons.file_copy
          );
        },
        barrierDismissible: false
      );

      List filesInfo = [];

      for (final PlatformFile file in result.files) {
        final String? filePath = file.path;

        if (filePath != null) {
          final String fileName = Uri.file(filePath).pathSegments.last;
          final List fileRoute = [...directoryRoute, fileName];
          final Uint8List fileBytes = File(filePath).readAsBytesSync();

          filesInfo.add({
            'route': fileRoute,
            'bytes': fileBytes
          });
        }
      }

      addFiles(filesInfo).then((_) => Navigator.of(context).pop());
    });
  }

  void requestFolderCreation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return PromptDialog(
          message: 'Selecione o nome da pasta',
          apply: (String folderName) {
            createFolder([...directoryRoute, folderName]).then((_) =>Navigator.of(context).pop());
          },
        );
      }
    );
  }

  void requestEntitySaving(BuildContext context, String entityType, List entityRoute, String entityName) {
    showDialog(
      context: context,
      builder: (context) {
        return const MessageDialog(
          message: 'Baixando item',
          iconData: Icons.download,
        );
      },
      barrierDismissible: false
    );

    if (entityType == 'file') {
      saveFile(entityRoute, entityName).then((_) => Navigator.of(context).pop());
    }

    if (entityType == 'directory') {
      saveFolder(entityRoute, entityName).then((_) => Navigator.of(context).pop());
    }
  }

  void requestEntityDeletion(BuildContext context, List entityRoute, String entityName) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmDialog(
          message: 'Você realmente deseja deletar',
          description: entityName,
          action: () {
            deleteEntity(entityRoute).then((_) => Navigator.of(context).pop());
          },
        );
      }
    );
  }

  Future<void> enterDirectory(String? newDirectoryName) async {
    try {
      List newDirectoryRoute = directoryRoute;

      if (newDirectoryName != null) newDirectoryRoute.add(newDirectoryName);

      final List? entities = await client?.listServerEntities(newDirectoryRoute);

      if (mounted && entities != null) {
        setState(() {
          if (newDirectoryName != null) directoryName = newDirectoryName;
          if (newDirectoryName != null) directoryRoute = newDirectoryRoute;

          serverEntities = entities;
        });
      }
    }
    
    catch(exception) {
      print(exception);
    }
  }

  Future<void> returnDirectory() async {
    try {
      if (directoryRoute.isNotEmpty) {
        final List newDirectoryRoute = directoryRoute.sublist(0, directoryRoute.length - 1);
        final List? entities = await client?.listServerEntities(newDirectoryRoute);

        if (mounted && entities != null) {
          setState(() {
            directoryName = newDirectoryRoute.isNotEmpty ? newDirectoryRoute.last : defaultDirectoryName;
            directoryRoute = newDirectoryRoute;
            serverEntities = entities;
          });
        }
      }
    }
    
    catch(exception) {
      print(exception);
    }
  }

  Future<void> addFiles(List filesInfo) async {
    try {
      await client?.writeServerFiles(filesInfo);

      final List? entities = await client?.listServerEntities(directoryRoute);

      if (mounted && entities != null) {
        setState(() {
          serverEntities = entities;
        });
      }
    }

    catch(exception) {
      print(exception);
    }
  }

  Future<void> saveFile(List fileRoute, String fileName) async {
    try {
      final String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Salve o arquivo',
        fileName: fileName
      );
      
      if (filePath == null) return;

      await client?.streamServerFile(fileRoute, File(filePath));
    }

    catch(exception) {
      print(exception);
    }
  }

  Future<void> createFolder(List folderRoute) async {
    try {
      await client?.createServerFolder(folderRoute);

      final List? entities = await client?.listServerEntities(directoryRoute);

      if (mounted && entities != null) {
        setState(() {
          serverEntities = entities;
        });
      }
    }

    catch(exception) {
      print(exception);
    }
  }

  Future<void> saveFolder(List folderRoute, String folderName) async {
    try {
      final String? folderRoot = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Selecione um destino'
      );

      if (folderRoot == null) return;

      final String folderPath = [folderRoot, folderName].join(Platform.pathSeparator);
      await client?.streamServerFolder(folderRoute, Directory(folderPath));
    }

    catch(exception) {
      print(exception);
    }
  }

  Future<void> deleteEntity(List entityRoute) async {
    try {
      await client?.deleteServerEntity(entityRoute);

      final List? entities = await client?.listServerEntities(directoryRoute);

      if (mounted && entities != null) {
        setState(() {
          serverEntities = entities;
        });
      }
    }
    
    catch(exception) {
      print(exception);
    }
  }
}