import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provides the current user's academic stage.
/// Cached after first fetch to avoid repeated Firestore reads.
class UserStageProvider {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  String? _cachedStage;
  String? _cachedUid;
  String? _cachedName;

  UserStageProvider({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  String? get currentUid => _auth.currentUser?.uid;

  /// Returns the user's stage string (primary, preparatory, secondary).
  /// Caches the result so subsequent calls don't hit Firestore.
  Future<String> getStage() async {
    if (_cachedStage != null && _cachedUid == currentUid) {
      return _cachedStage!;
    }

    final uid = currentUid;
    if (uid == null) return 'primary';

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      _cachedStage = doc.data()?['stage'] ?? 'primary';
      _cachedUid = uid;
      _cachedName = doc.data()?['name'];
      return _cachedStage!;
    } catch (_) {
      return 'primary';
    }
  }

  /// Returns the user's display name (cached).
  Future<String> getName() async {
    if (_cachedName != null && _cachedUid == currentUid) {
      return _cachedName!;
    }
    await getStage(); // This also caches the name
    return _cachedName ?? 'طالب';
  }

  /// Clears cache (call on logout).
  void clearCache() {
    _cachedStage = null;
    _cachedUid = null;
    _cachedName = null;
  }
}
