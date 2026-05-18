import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_settings.dart';
import '../models/notification_record.dart';
import '../utils/app_constants.dart';

class FirestoreService {
  FirestoreService({
    required FirebaseFirestore? firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  bool get isAvailable => _firestore != null;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore!
        .collection(AppConstants.usersCollection)
        .doc(uid);
  }

  Future<AppSettings?> fetchSettings(String uid) async {
    if (!isAvailable) {
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _userDoc(uid).get();
    final Map<String, dynamic>? data = snapshot.data();
    final Map<String, dynamic>? preferences =
        data?['preferences'] as Map<String, dynamic>?;
    if (preferences == null) {
      return null;
    }

    return AppSettings.fromJson(preferences);
  }

  Future<void> upsertUserProfile(User user, AppSettings settings) async {
    if (!isAvailable) {
      return;
    }

    await _userDoc(user.uid).set(
      <String, dynamic>{
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'preferences': settings.toJson(),
        'updatedAt': settings.updatedAt.millisecondsSinceEpoch,
        'lastSeenAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> syncLastAlert(String uid, NotificationRecord record) async {
    if (!isAvailable) {
      return;
    }

    await _userDoc(uid).set(
      <String, dynamic>{
        'lastAlert': record.toJson(),
        'lastAlertAt': record.receivedAt.millisecondsSinceEpoch,
        'lastSeenAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
