import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TowStore {
  TowStore(this.username);
  final String username;
  Future<void> _writes = Future.value();

  String key(String role) => 'tow.$role.$username';
  Future<Map<String, dynamic>?> session(String role) async {
    final value = (await SharedPreferences.getInstance()).getString(key(role));
    return value == null ? null : jsonDecode(value) as Map<String, dynamic>;
  }

  Future<void> saveSession(String role, Map<String, dynamic>? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key(role));
    } else {
      await prefs.setString(key(role), jsonEncode(value));
    }
  }

  Future<Directory> directory() async {
    final root = await getApplicationSupportDirectory();
    return Directory('${root.path}/tows/${Uri.encodeComponent(username)}')
        .create(recursive: true);
  }

  Future<void> append(String code, Map<String, dynamic> record) {
    final operation = _writes.then((_) async {
      final dir = await directory();
      await File('${dir.path}/$code.jsonl').writeAsString(
          '${jsonEncode(record)}\n',
          mode: FileMode.append,
          flush: true);
    });
    _writes = operation.catchError((Object _) {});
    return operation;
  }

  Future<List<File>> files() async {
    final dir = await directory();
    final files = await dir
        .list()
        .where((e) => e is File && e.path.endsWith('.jsonl'))
        .cast<File>()
        .toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  Future<List<Map<String, dynamic>>> read(File file) async {
    final records = <Map<String, dynamic>>[];
    for (final line in await file.readAsLines()) {
      try {
        records.add(jsonDecode(line) as Map<String, dynamic>);
      } on FormatException {
        /* Ignore a partial final write after process termination. */
      }
    }
    return records;
  }
}
