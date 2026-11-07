import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

/// Thrown when a user logs in but has not verified their email yet.
/// Having our own exception lets the UI know exactly what happened.
class NotVerifiedException implements Exception {
  final String message = 'Please verify your email first. Check your inbox.';
}

/// This class is the ONLY place that talks to Firebase Auth.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Check your real ALU email and edit this list if needed.
  static const List<String> allowedDomains = [
    'alustudent.com',
    'alueducation.com',
  ];

  // "static" means we can call AuthService.isAluEmail(...) without
  // creating an AuthService object.
  static bool isAluEmail(String email) {
    final domain = email.trim().toLowerCase().split('@').last;
    return allowedDomains.contains(domain);
  }

  // Emits a new value whenever someone logs in or out.
  Stream<User?> get authChanges => _auth.authStateChanges();

  // Turns Firebase's technical error codes into friendly messages.
  String _friendlyMessage(FirebaseAuthException e) {
    debugPrint('FIREBASE AUTH code: ${e.code}');
    debugPrint('FIREBASE AUTH message: ${e.message}');

    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Wrong email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      default:
        // Show the code so we can see what really happened.
        return 'Error (${e.code}): ${e.message}';
    }
  }

  Future<void> register(String name, String email, String password) async {
    if (!isAluEmail(email)) {
      throw Exception('Please use your ALU email address.');
    }

    try {
      // 1. Create the account in Firebase Authentication.
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;

      // 2. Save the name on the account.
      await user.updateDisplayName(name);

      // 3. Save a profile in Firestore. Everyone starts as a student.
      //    Staff roles are set manually in the Firebase Console.
      final newUser = AppUser(
        uid: user.uid,
        name: name,
        email: email.trim(),
        role: 'student',
      );
      await _db.collection('users').doc(user.uid).set(newUser.toMap());

      // 4. Send the verification email, then log out until they verify.
      await user.sendEmailVerification();
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Refresh the user so emailVerified is up to date.
      await credential.user!.reload();

      if (!_auth.currentUser!.emailVerified) {
        await _auth.signOut();
        throw NotVerifiedException();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  Future<void> resendVerification(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user!.sendEmailVerification();
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyMessage(e));
    }
  }

  // Reads the user's profile (name, role) from Firestore.
  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }

  Future<void> logout() => _auth.signOut();
}
