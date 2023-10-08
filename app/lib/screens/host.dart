import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:projetus_cloud/target/server.dart';
import 'package:projetus_cloud/shared/metadata.dart';
import 'package:projetus_cloud/shared/composer.dart';
import 'package:projetus_cloud/widgets/buttons/sync_button.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({super.key});
  @override HostScreenState createState() => HostScreenState();
}

class HostScreenState extends State<HostScreen> {
  Server? server;
  DiskState diskState = DiskState.selectable;

  @override Widget build(BuildContext context) {
    late IconData diskIconData;
    late Color diskStateColor;
    late String diskStateText;

    if (diskState == DiskState.selectable) {
      diskIconData = Icons.disc_full;
      diskStateColor = Colors.grey.shade500;
      diskStateText = 'Selecionar disco';
    }

    if (diskState == DiskState.selecting) {
      diskIconData = Icons.disc_full;
      diskStateColor = Colors.yellow.shade800;
      diskStateText = 'Preparando disco';
    }

    if (diskState == DiskState.selected) {
      final folderPath = server?.storage.path;

      if (folderPath != null) {
        diskIconData = Icons.wifi;
        diskStateColor = Theme.of(context).primaryColor;
        diskStateText = 'Sincronizando: ${Uri.file(folderPath).pathSegments.last}';
      }
    }

    if (diskState == DiskState.error) {
      diskIconData = Icons.error;
      diskStateColor = Colors.red;
      diskStateText = 'Erro interno';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servidor'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SyncButton(
              iconData: diskIconData,
              color: diskStateColor,
              text: diskStateText,
              action: () => syncDisk()
            )
          ]
        )
      )
    );
  }

  @override void dispose() {
    super.dispose();
    server?.stopListening();
    server?.stopSyncingIP();
  }

  Future<void> syncDisk() async {
    if (diskState != DiskState.selected) {
      if (mounted) setState(() => diskState = DiskState.selecting);

      final String? storageName = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Selecione um disco'
      );

      if (storageName != null) {
        final Metadata metadata = await Composer.fetchMetadata();

        server = Server(
          metadata: metadata,
          storage: Directory(storageName)
        );

        try {
          await server?.startListening();
          await server?.startSyncingIP();

          if (mounted) setState(() => diskState = DiskState.selected);
        }

        catch(exception) {
          print(exception);
          if (mounted) setState(() => diskState = DiskState.error);
        }
      }
      
      else {
        if (mounted) setState(() => diskState = DiskState.selectable);
      }
    }
  }
}

enum DiskState {
  selectable,
  selecting,
  selected,
  error
}