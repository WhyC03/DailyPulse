import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';

class LocalStorageService {
  static const String _moodEntriesKey = 'mood_entries';

  // Save mood entries to local storage
  static Future<void> saveMoodEntries(List<MoodEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = entries.map((entry) => entry.toJson()).toList();
    final jsonString = jsonEncode(entriesJson);
    await prefs.setString(_moodEntriesKey, jsonString);
  }

  // Load mood entries from local storage
  static Future<List<MoodEntry>> loadMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_moodEntriesKey);
    
    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> entriesJson = jsonDecode(jsonString);
      return entriesJson.map((json) => MoodEntry.fromJson(json)).toList();
    } catch (e) {
      print('Error loading mood entries: $e');
      return [];
    }
  }

  // Add a new mood entry
  static Future<void> addMoodEntry(MoodEntry entry) async {
    final entries = await loadMoodEntries();
    entries.add(entry);
    await saveMoodEntries(entries);
  }

  // Update an existing mood entry
  static Future<void> updateMoodEntry(MoodEntry entry) async {
    final entries = await loadMoodEntries();
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      entries[index] = entry;
      await saveMoodEntries(entries);
    }
  }

  // Delete a mood entry
  static Future<void> deleteMoodEntry(String entryId) async {
    final entries = await loadMoodEntries();
    entries.removeWhere((entry) => entry.id == entryId);
    await saveMoodEntries(entries);
  }

  // Clear all mood entries
  static Future<void> clearMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_moodEntriesKey);
  }

  // Get mood entries for a specific user
  static Future<List<MoodEntry>> getMoodEntriesForUser(String userId) async {
    final entries = await loadMoodEntries();
    return entries.where((entry) => entry.userId == userId).toList();
  }

  // Get mood entries for a specific date
  static Future<MoodEntry?> getMoodEntryForDate(DateTime date, String userId) async {
    final entries = await getMoodEntriesForUser(userId);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    for (final entry in entries) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (entryDate.isAtSameMomentAs(targetDate)) {
        return entry;
      }
    }
    return null;
  }
}
