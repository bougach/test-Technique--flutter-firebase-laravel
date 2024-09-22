import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return "Please enter all the fields";
      }

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("users").doc(cred.user!.uid).set({
        'name': name,
        'uid': cred.user!.uid,
        'email': email,
      });

      return "success";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'The account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return e.message ?? "An error occurred during sign up";
      }
    } catch (err) {
      return "An unexpected error occurred: ${err.toString()}";
    }
  }

  Future<Map<String, String>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return {"error": "Please enter all the fields"};
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? token = await userCredential.user?.getIdToken();

      if (token != null) {
        return {"success": token};
      } else {
        return {"error": "Failed to get token"};
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return {"error": 'No user found for that email.'};
        case 'wrong-password':
          return {"error": 'Wrong password provided for that user.'};
        case 'invalid-email':
          return {"error": 'The email address is not valid.'};
        case 'user-disabled':
          return {"error": 'This user account has been disabled.'};
        default:
          return {"error": e.message ?? "An error occurred during login"};
      }
    } catch (err) {
      return {"error": "An unexpected error occurred: ${err.toString()}"};
    }
  }

  Future<String?> getIdToken() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
