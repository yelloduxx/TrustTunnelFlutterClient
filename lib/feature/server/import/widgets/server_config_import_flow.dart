import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/feature/server/import/domain/service/server_config_import_service.dart';
import 'package:trusttunnel/feature/server/servers/widget/scope/servers_scope.dart';

abstract final class ServerConfigImportFlow {
  static Future<void> showImportOptions(
    BuildContext context, {
    VoidCallback? onAddManually,
  }) async {
    final option = await showModalBottomSheet<_ImportOption>(
      context: context,
      useRootNavigator: false,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_open_outlined),
              title: Text(context.ln.importConfigFromFile),
              onTap: () => Navigator.of(context).pop(_ImportOption.file),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(context.ln.importConfigFromLink),
              onTap: () => Navigator.of(context).pop(_ImportOption.link),
            ),
            ListTile(
              leading: const Icon(Icons.content_paste),
              title: Text(context.ln.importConfigFromClipboard),
              onTap: () => Navigator.of(context).pop(_ImportOption.clipboard),
            ),
            if (onAddManually != null)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(context.ln.addServerManually),
                onTap: () => Navigator.of(context).pop(_ImportOption.manual),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (option == null || !context.mounted) {
      return;
    }

    switch (option) {
      case _ImportOption.file:
        await importFromFile(context);
        break;
      case _ImportOption.link:
        await _importFromLink(context);
        break;
      case _ImportOption.clipboard:
        await _importFromClipboard(context);
        break;
      case _ImportOption.manual:
        onAddManually?.call();
        break;
    }
  }

  static Future<void> importFromFile(BuildContext context) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: const [
        'toml',
      ],
      withData: true,
    );

    if (picked == null || picked.files.isEmpty || !context.mounted) {
      return;
    }

    final file = picked.files.first;
    final bytes = file.bytes;
    final path = file.path;
    final service = _service(context);

    try {
      if (bytes == null && path == null) {
        throw const FormatException('Picked file has no readable payload');
      }

      final content = bytes != null ? utf8.decode(bytes, allowMalformed: true) : await File(path!).readAsString();

      final importedServerName = await service.importFromToml(
        content: content,
        fallbackName: file.name.replaceAll(RegExp(r'\.toml$', caseSensitive: false), ''),
      );

      if (!context.mounted) {
        return;
      }

      _onImportSuccess(context, importedServerName: importedServerName);
    } on FormatException {
      if (!context.mounted) return;
      context.showInfoSnackBar(message: context.ln.importConfigInvalidFormat);
    } catch (_) {
      if (!context.mounted) return;
      context.showInfoSnackBar(message: context.ln.importConfigFailed);
    }
  }

  static Future<void> importFromUri(
    BuildContext context, {
    required Uri uri,
    bool silent = false,
  }) async {
    final service = _service(context);
    try {
      final importedServerName = await service.importFromUri(uri: uri);

      if (!context.mounted) {
        return;
      }

      _onImportSuccess(context, importedServerName: importedServerName, silent: silent);
    } on FormatException {
      if (!context.mounted || silent) return;
      context.showInfoSnackBar(message: context.ln.importConfigInvalidFormat);
    } catch (_) {
      if (!context.mounted || silent) return;
      context.showInfoSnackBar(message: context.ln.importConfigFailed);
    }
  }

  static Future<void> _importFromLink(BuildContext context) async {
    final controller = TextEditingController();

    final link = await showDialog<String>(
      context: context,
      useRootNavigator: false,
      builder: (context) => AlertDialog(
        title: Text(context.ln.importConfigFromLink),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.ln.importConfigLinkHint,
          ),
          minLines: 1,
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.ln.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(context.ln.importConfig),
          ),
        ],
      ),
    );

    controller.dispose();

    if (link == null || link.trim().isEmpty || !context.mounted) {
      return;
    }

    final uri = Uri.tryParse(link.trim());
    if (uri == null) {
      context.showInfoSnackBar(message: context.ln.importConfigInvalidFormat);
      return;
    }

    await importFromUri(context, uri: uri);
  }

  static void _onImportSuccess(
    BuildContext context, {
    required String importedServerName,
    bool silent = false,
  }) {
    ServersScope.controllerOf(context, listen: false).fetchServers();

    if (!silent) {
      context.showInfoSnackBar(
        message: context.ln.serverImportedSnackbar(importedServerName),
      );
    }
  }

  static Future<void> _importFromClipboard(BuildContext context) async {
    final clipboardData = await Clipboard.getData('text/plain');
    final text = clipboardData?.text?.trim();

    if (text == null || text.isEmpty) {
      if (!context.mounted) return;
      context.showInfoSnackBar(message: context.ln.importConfigClipboardEmpty);
      return;
    }

    final uri = Uri.tryParse(text);
    if (uri == null) {
      if (!context.mounted) return;
      context.showInfoSnackBar(message: context.ln.importConfigInvalidFormat);
      return;
    }

    if (!context.mounted) return;
    await importFromUri(context, uri: uri);
  }

  static ServerConfigImportService _service(BuildContext context) {
    final repositories = context.repositoryFactory;

    return ServerConfigImportService(
      serverRepository: repositories.serverRepository,
      routingRepository: repositories.routingRepository,
    );
  }
}

enum _ImportOption {
  file,
  link,
  clipboard,
  manual,
}
