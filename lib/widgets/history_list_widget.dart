import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/text_entry.dart';
import '../constants/app_constants.dart';
import '../utils/date_utils.dart' as app_date_utils;

class HistoryListWidget extends StatelessWidget {
  final List<TextEntry> textHistory;
  final Function(TextEntry) onSelectText;
  final Function(String) onDeleteEntry;

  const HistoryListWidget({
    super.key,
    required this.textHistory,
    required this.onSelectText,
    required this.onDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    if (textHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              AppConstants.historyEmptyMessage,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: textHistory.length,
      itemBuilder: (context, index) {
        final entry = textHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              _getIconForSource(entry.source),
              color: _getColorForSource(entry.source),
            ),
            title: Text(
              entry.text.length > 50 
                  ? '${entry.text.substring(0, 50)}...'
                  : entry.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${app_date_utils.DateUtils.formatDate(entry.timestamp)} • ${_getLabelForSource(entry.source)}',
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'select',
                  child: ListTile(
                    leading: Icon(Icons.check),
                    title: Text(AppConstants.menuUseText),
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text(AppConstants.menuShare),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text(AppConstants.menuDelete),
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'select':
                    onSelectText(entry);
                    break;
                  case 'share':
                    Share.share(entry.text, subject: AppConstants.shareSubject);
                    break;
                  case 'delete':
                    onDeleteEntry(entry.id);
                    break;
                }
              },
            ),
            onTap: () => onSelectText(entry),
          ),
        );
      },
    );
  }

  IconData _getIconForSource(String source) {
    switch (source) {
      case AppConstants.sourceCamera:
        return Icons.camera_alt;
      case AppConstants.sourceMicrophone:
        return Icons.mic;
      case AppConstants.sourceEdited:
        return Icons.edit;
      default:
        return Icons.text_fields;
    }
  }

  Color _getColorForSource(String source) {
    switch (source) {
      case AppConstants.sourceCamera:
        return Colors.blue;
      case AppConstants.sourceMicrophone:
        return Colors.red;
      case AppConstants.sourceEdited:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getLabelForSource(String source) {
    switch (source) {
      case AppConstants.sourceCamera:
        return AppConstants.sourceCameraLabel;
      case AppConstants.sourceMicrophone:
        return AppConstants.sourceMicrophoneLabel;
      case AppConstants.sourceEdited:
        return AppConstants.sourceEditedLabel;
      default:
        return 'Desconocido';
    }
  }
}
