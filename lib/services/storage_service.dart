import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

class StorageService {
  static Future<Directory> _appDir() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir;
  }

  static Future<File> _notesFile() async {
    final dir = await _appDir();
    return File('${dir.path}/notes.json');
  }

  static Future<List<Note>> loadNotes() async {
    try { 
      final f = await _notesFile();
      if (!await f.exists()) return [];
      final content = await f.readAsString();
      if (content.isEmpty) return [];
      final List<dynamic> data = json.decode(content);
      return data.map((e) => Note.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveNotes(List<Note> notes) async {
    final f = await _notesFile();
    final jsonStr = json.encode(notes.map((n) => n.toMap()).toList());
    await f.writeAsString(jsonStr);
  }

  static Future<String> saveImageFile(File image) async {
    final dir = await _appDir();
    final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '_' + image.path.split('/').last;
    final newPath = '${dir.path}/\$fileName';
    final newFile = await image.copy(newPath);
    return newFile.path;
  }

  static Future<void> deleteImage(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
