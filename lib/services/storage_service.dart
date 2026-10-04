import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry_model.dart';

class StorageService {
  final String _storageKey = 'entries';

  Future<void> saveEntry(Entry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> entries = prefs.getStringList(_storageKey) ?? [];
    entries.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_storageKey, entries);
  }

  Future<List<Entry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> entries = prefs.getStringList(_storageKey) ?? [];
    return entries.map((e) => Entry.fromJson(jsonDecode(e))).toList();
  }
}
