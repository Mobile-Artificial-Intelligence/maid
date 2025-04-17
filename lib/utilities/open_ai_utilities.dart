part of 'package:maid/main.dart';

class OpenAiUtilities {
  static List<Map<String, dynamic>> openAiMapper(List<Map<String, dynamic>> mapList) {
    final removedKeys = <String>['client-created-root'];
    final result = <Map<String, dynamic>>[];

    for (final conversation in mapList) {
      if (conversation.containsKey('mapping')) {
        final mapping = conversation['mapping'];
        if (mapping is Map<String, dynamic>) {
          result.addAll(_processMapping(mapping, removedKeys));
        }
      }
    }

    return result;
  }

  static List<Map<String, dynamic>> _processMapping(
    Map<String, dynamic> mapping,
    List<String> removedKeys,
  ) {
    final result = <Map<String, dynamic>>[];

    for (final entry in mapping.entries) {
      final key = entry.key;
      final value = entry.value;

      if (key == 'client-created-root' || value is! Map<String, dynamic>) {
        continue;
      }

      if (removedKeys.contains(value['parent'])) {
        value['parent'] = null;
      }

      if (value['parent'] == null && value['message'] == null) {
        removedKeys.add(key);
        continue;
      }

      final messageData = value['message'] ?? {};
      final content = messageData['content'] ?? {};
      final text = _extractText(content);

      final message = <String, dynamic>{
        'id': key,
        'parent': value['parent'],
        'content': text,
        'role': messageData['author']?['role'],
        'children': value['children'] ?? [],
        'create_time': _toIso8601(messageData['create_time']),
        'update_time': _toIso8601(messageData['update_time']),
      };

      result.add(message);
    }

    return result;
  }

  static String _extractText(Map<String, dynamic> content) {
    final contentType = content['content_type'];

    if (contentType == 'text') {
      return (content['parts'] as List)
          .map((part) => part.toString())
          .join('\n')
          .trimRight();
    }

    if (contentType == 'code') {
      return content['text']?.toString() ?? '';
    }

    return 'Error In Message Parse';
  }

  static String? _toIso8601(dynamic timestamp) {
    if (timestamp is num) {
      try {
        final milliseconds = (timestamp * 1000).toInt();
        final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
        return dateTime.toIso8601String();
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
