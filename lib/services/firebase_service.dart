import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry.dart';
import '../models/user.dart' as app_user;

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Authentication methods
  static Future<UserCredential?> signUp(String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(displayName);
      
      // Save user to Firestore
      final user = app_user.User(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
      );
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      
      return credential;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  static Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mood entries methods
  static Future<void> saveMoodEntry(MoodEntry entry) async {
    try {
      await _firestore
          .collection('mood_entries')
          .doc(entry.id)
          .set(entry.toMap());
    } catch (e) {
      print('Error saving mood entry: $e');
      rethrow;
    }
  }

  static Future<void> updateMoodEntry(MoodEntry entry) async {
    try {
      await _firestore
          .collection('mood_entries')
          .doc(entry.id)
          .update(entry.toMap());
    } catch (e) {
      print('Error updating mood entry: $e');
      rethrow;
    }
  }

  static Future<void> deleteMoodEntry(String entryId) async {
    try {
      await _firestore
          .collection('mood_entries')
          .doc(entryId)
          .delete();
    } catch (e) {
      print('Error deleting mood entry: $e');
      rethrow;
    }
  }

  static Stream<List<MoodEntry>> getMoodEntriesForUser(String userId) {
    return _firestore
        .collection('mood_entries')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final entries = snapshot.docs.map((doc) {
        return MoodEntry.fromMap(doc.data());
      }).toList();
      
      // Sort by date in descending order (newest first)
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    });
  }

  static Future<MoodEntry?> getMoodEntryForDate(DateTime date, String userId) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('mood_entries')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('date', isLessThan: endOfDay.millisecondsSinceEpoch)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return MoodEntry.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error getting mood entry for date: $e');
      return null;
    }
  }

  // Analytics methods
  static Future<Map<String, int>> getMoodAnalytics(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('mood_entries')
          .where('userId', isEqualTo: userId)
          .get();

      int positiveCount = 0;
      int negativeCount = 0;
      int neutralCount = 0;

      for (final doc in querySnapshot.docs) {
        final entry = MoodEntry.fromMap(doc.data());
        if (entry.isPositive) {
          positiveCount++;
        } else if (entry.isNegative) {
          negativeCount++;
        } else if (entry.isNeutral) {
          neutralCount++;
        }
      }

      return {
        'total': querySnapshot.docs.length,
        'positive': positiveCount,
        'negative': negativeCount,
        'neutral': neutralCount,
      };
    } catch (e) {
      print('Error getting mood analytics: $e');
      return {
        'total': 0,
        'positive': 0,
        'negative': 0,
        'neutral': 0,
      };
    }
  }
}
